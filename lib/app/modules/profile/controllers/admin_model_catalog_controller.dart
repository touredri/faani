import 'dart:io';

import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/admin_audit_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:get/get.dart';

class AdminModelCatalogController extends GetxController {
  AdminModelCatalogController({
    ModeleService? modeleService,
    AdminAuditService? auditService,
  })  : _modeleService = modeleService ?? ModeleService(),
        _auditService = auditService ?? AdminAuditService(),
        _userService = UserService();

  final ModeleService _modeleService;
  final AdminAuditService _auditService;
  final UserService _userService;
  final isSaving = false.obs;

  String get _adminId {
    final id = auth.currentUser?.uid;
    if (id == null || id.isEmpty) {
      throw const FormatException('Session administrateur expirée.');
    }
    return id;
  }

  Future<void> createFaaniContent({
    required String detail,
    required String genreHabit,
    required String categoryId,
    required bool isPublic,
    required List<File> images,
  }) async {
    final adminId = _adminId;
    await _runSaving(() async {
      final modelId = await _modeleService.createFaaniContent(
        adminId: adminId,
        detail: detail,
        genreHabit: genreHabit,
        categoryId: categoryId,
        isPublic: isPublic,
        imageFiles: images,
      );
      await _auditService.logAction(
        action: 'create_faani_model',
        targetType: 'modele',
        targetId: modelId,
        metadata: {
          'categoryId': categoryId,
          'genreHabit': genreHabit,
          'isPublic': isPublic,
          'imageCount': images.length,
        },
      );
    });
  }

  Future<void> updateModel({
    required Modele modele,
    required String detail,
    required String genreHabit,
    required String categoryId,
    required bool isPublic,
    List<File> replacementImages = const <File>[],
  }) async {
    final id = _modelId(modele);
    await _runSaving(() async {
      await _modeleService.updateAdminModelDetails(
        modeleId: id,
        detail: detail,
        genreHabit: genreHabit,
        categoryId: categoryId,
        isPublic: isPublic,
      );
      await _auditService.logAction(
        action: 'update_model_details',
        targetType: 'modele',
        targetId: id,
        metadata: {
          'categoryId': categoryId,
          'genreHabit': genreHabit,
          'isPublic': isPublic,
        },
      );
      if (replacementImages.isNotEmpty) {
        await _modeleService.replaceAdminModelMedia(
          modele: modele,
          imageFiles: replacementImages,
        );
        await _auditService.logAction(
          action: 'replace_model_media',
          targetType: 'modele',
          targetId: id,
          metadata: {'imageCount': replacementImages.length},
        );
      }
    });
  }

  Future<void> publish(Modele modele) => _changeLifecycle(
        modele,
        action: 'publish_model',
        mutate: (id, adminId) => _modeleService.publishModel(
          modeleId: id,
          adminId: adminId,
        ),
      );

  Future<void> depublish(Modele modele) => _changeLifecycle(
        modele,
        action: 'depublish_model',
        mutate: (id, adminId) => _modeleService.depublishModel(
          modeleId: id,
          adminId: adminId,
        ),
      );

  Future<void> reject(Modele modele, String reason) => _changeLifecycle(
        modele,
        action: 'reject_model',
        metadata: {'reason': reason.trim()},
        mutate: (id, adminId) => _modeleService.updateModelModeration(
          modeleId: id,
          isApproved: false,
          adminId: adminId,
          reason: reason,
        ),
      );

  Future<void> restore(Modele modele) => _changeLifecycle(
        modele,
        action: 'restore_model_to_pending',
        mutate: (id, adminId) => _modeleService.restoreModelToPending(
          modeleId: id,
          adminId: adminId,
        ),
      );

  Future<void> _changeLifecycle(
    Modele modele, {
    required String action,
    required Future<void> Function(String modelId, String adminId) mutate,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final id = _modelId(modele);
    final adminId = _adminId;
    await _runSaving(() async {
      await mutate(id, adminId);
      await _auditService.logAction(
        action: action,
        targetType: 'modele',
        targetId: id,
        metadata: {
          'tailorId': modele.idTailleur,
          'isFaaniContent': modele.isFaaniContent,
          ...metadata,
        },
      );
      await _notifyTailorAboutLifecycle(
        modele,
        action: action,
        reason: metadata['reason']?.toString(),
      );
    });
  }

  Future<void> _notifyTailorAboutLifecycle(
    Modele modele, {
    required String action,
    String? reason,
  }) async {
    if (modele.isFaaniContent) return;

    final target = await _userService.getIfUser(modele.idTailleur);
    final token = target?.token?.trim() ?? '';
    if (token.isEmpty) return;

    final detail = (modele.detail ?? '').trim();
    final modelName = detail.isEmpty ? 'Votre modèle' : detail;
    final message = switch (action) {
      'publish_model' => '$modelName est maintenant publié sur Faani.',
      'depublish_model' => '$modelName a été dépublié par l’administration.',
      'reject_model' => reason?.trim().isNotEmpty == true
          ? '$modelName a été refusé: ${reason!.trim()}'
          : '$modelName a été refusé par l’administration.',
      'restore_model_to_pending' =>
        '$modelName a été restauré et attend une nouvelle validation.',
      _ => '',
    };
    if (message.isEmpty) return;

    await sendNotification(
      token,
      'Statut de votre modèle',
      message,
      category: 'modelModeration',
      targetType: 'modele',
      targetId: _modelId(modele),
    );
    await _auditService.logAction(
      action: 'notify_tailor_model_status',
      targetType: 'modele',
      targetId: _modelId(modele),
      metadata: {
        'tailorId': modele.idTailleur,
        'lifecycleAction': action,
      },
    );
  }

  Future<void> _runSaving(Future<void> Function() operation) async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      await operation();
    } finally {
      isSaving.value = false;
    }
  }

  String _modelId(Modele modele) {
    final id = modele.id;
    if (id == null || id.isEmpty) {
      throw const FormatException('Modèle introuvable.');
    }
    return id;
  }
}
