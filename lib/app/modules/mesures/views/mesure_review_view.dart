import 'package:faani/app/data/repositories/firestore_mesure_repository.dart';
import 'package:faani/app/domain/mesures/mesure_draft.dart';
import 'package:faani/app/domain/mesures/mesure_draft_mapper.dart';
import 'package:faani/app/domain/mesures/mesure_field.dart';
import 'package:faani/app/domain/mesures/mesure_repository.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/mesures/mesure_strings.dart';
import 'package:faani/app/modules/mesures/views/mesures_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MesureReviewView extends StatefulWidget {
  const MesureReviewView({
    super.key,
    required this.draft,
    this.repository,
  });

  final MesureDraft draft;
  final MesureRepository? repository;

  @override
  State<MesureReviewView> createState() => _MesureReviewViewState();
}

class _MesureReviewViewState extends State<MesureReviewView> {
  late MesureDraft _draft;
  late final Map<MesureField, TextEditingController> _controllers;
  final _nameController = TextEditingController();
  var _isSaving = false;

  MesureRepository get _repository =>
      widget.repository ?? FirestoreMesureRepository();

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _controllers = {
      for (final field in MesureField.values)
        field: TextEditingController(text: '${_draft.values[field] ?? ''}'),
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    _syncDraftFromControllers();
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        MesureStrings.t('mesures_review_name_required_title',
            fallback: 'Nom requis'),
        MesureStrings.t(
          'mesures_review_name_required_body',
          fallback: 'Donnez un nom à cette fiche de mesures.',
        ),
      );
      return;
    }
    if (!_draft.isComplete) {
      Get.snackbar(
        MesureStrings.t('mesures_review_incomplete_title',
            fallback: 'Mesures incomplètes'),
        MesureStrings.t(
          'mesures_review_incomplete_body',
          fallback: 'Renseignez toutes les valeurs avant d\'enregistrer.',
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _repository.create(
        _draft.toMesure(
          userId: user!.uid,
          name: _nameController.text.trim(),
        ),
      );
      if (!mounted) {
        return;
      }
      Get.until((route) => route.settings.name == '/mesures' || route.isFirst);
      if (Get.currentRoute != '/mesures') {
        Get.off(() => const MesuresView());
      }
    } catch (_) {
      Get.snackbar(
        MesureStrings.t('mesures_review_save_error_title', fallback: 'Erreur'),
        MesureStrings.t(
          'mesures_review_save_error_body',
          fallback: 'Impossible d\'enregistrer la mesure.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _syncDraftFromControllers() {
    var draft = _draft;
    for (final field in MesureField.values) {
      final parsed = int.tryParse(_controllers[field]!.text) ?? 0;
      draft = draft.copyWithValue(
        field: field,
        valueCm: parsed,
        source: _draft.sources[field] == MesureValueSource.camera &&
                parsed == _draft.values[field]
            ? MesureValueSource.camera
            : MesureValueSource.manual,
        confidence: _draft.confidences[field] ?? 1,
      );
    }
    _draft = draft;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MesureStrings.t('mesures_review_title',
              fallback: 'Vérifier les mesures'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: MesureStrings.t(
                'mesures_review_name_label',
                fallback: 'Nom de la fiche',
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          3.hs,
          ...MesureField.values.map((field) {
            final source = _draft.sources[field];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(field.label, style: const TextStyle(fontSize: 16)),
                        if (source == MesureValueSource.camera)
                          Text(
                            MesureStrings.t(
                              'mesures_review_camera_estimate',
                              fallback: 'Estimé par caméra',
                            ),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _controllers[field],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        suffixText: 'cm',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          3.hs,
          FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    MesureStrings.t('mesures_review_save',
                        fallback: 'Enregistrer'),
                  ),
          ),
        ],
      ),
    );
  }
}
