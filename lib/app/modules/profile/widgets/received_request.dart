import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/tailleur_request.dart';
import 'package:faani/app/data/models/user_role.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/commande_service.dart';
import 'package:faani/app/data/services/access_control_service.dart';
import 'package:faani/app/data/services/admin_audit_service.dart';
import 'package:faani/app/data/services/tailleur_request_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TailleurRequestController extends GetxController {
  final TailleurRequestService service = TailleurRequestService();
  final AdminAuditService _auditService = AdminAuditService();
  final _usersService = UserService();

  Stream<List<Map<String, dynamic>>> getRecentAuditLogs({int limit = 120}) {
    return _auditService.getRecentLogs(limit: limit);
  }

  Stream<List<TailleurRequest>> getRequestsByApprovalStatus(bool status) {
    return service.getRequestsByApprovalStatus(status);
  }

  Future<bool> isCurrentUserAdmin() async {
    return AccessControlService().isCurrentUserAdmin();
  }

  Future<void> approveRequest(TailleurRequest request) async {
    if (request.id == null) return;
    await service.updateRequestApprovalStatus(request.id!, true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(request.userId)
        .update({
      'isTailleur': true,
      'role': appUserRoleToString(AppUserRole.tailor),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final target = await _usersService.getIfUser(request.userId);
    final token = target?.token;
    if (token != null && token.trim().isNotEmpty) {
      await sendNotification(
        token,
        'Statut demande',
        'Votre requête pour passer en compte tailleur a été approuvée.',
      );
    }

    await _auditService.logAction(
      action: 'approve_tailor_request',
      targetType: 'tailorRequest',
      targetId: request.id!,
      metadata: {
        'userId': request.userId,
        'atelier': request.nomAtelier,
      },
    );
  }

  Future<void> rejectAndDeleteRequest(TailleurRequest request) async {
    if (request.id == null) return;
    await service.deleteRequest(request.id!);
    await _auditService.logAction(
      action: 'reject_tailor_request',
      targetType: 'tailorRequest',
      targetId: request.id!,
      metadata: {
        'userId': request.userId,
        'atelier': request.nomAtelier,
      },
    );
  }

  Future<void> updateUserTailleurStatus(UserModel user, bool isTailleur) {
    final uid = user.id;
    if (uid == null || uid.isEmpty) {
      return Future.value();
    }
    return _usersService.updateUserIsTailleur(uid, isTailleur).then((_) async {
      await _auditService.logAction(
        action: isTailleur ? 'promote_tailor' : 'demote_tailor',
        targetType: 'user',
        targetId: uid,
        metadata: {
          'name': user.nomPrenom ?? '',
        },
      );
    });
  }

  Future<void> approveModel(Modele model) async {
    final id = model.id;
    if (id == null || id.isEmpty) return;
    await ModeleService().updateModelApprovalStatus(id, true);
    await _auditService.logAction(
      action: 'approve_model',
      targetType: 'modele',
      targetId: id,
      metadata: {
        'tailorId': model.idTailleur,
      },
    );
  }

  Future<void> rejectModel(Modele model) async {
    final id = model.id;
    if (id == null || id.isEmpty) return;
    await ModeleService().updateModelApprovalStatus(id, false);
    await _auditService.logAction(
      action: 'reject_model',
      targetType: 'modele',
      targetId: id,
      metadata: {
        'tailorId': model.idTailleur,
      },
    );
  }

  Future<void> logBroadcast({
    required String audience,
    required String title,
    required int recipientCount,
  }) {
    return _auditService.logAction(
      action: 'broadcast_notification',
      targetType: 'broadcast',
      targetId: DateTime.now().millisecondsSinceEpoch.toString(),
      metadata: {
        'audience': audience,
        'title': title,
        'recipientCount': recipientCount,
      },
    );
  }

  // get request by tailleur id
  Future<TailleurRequest?> getRequest(String userId) async {
    return service.getRequestByUserId(userId);
  }
}

class ReceivedRequest extends StatefulWidget {
  const ReceivedRequest({super.key});

  @override
  State<ReceivedRequest> createState() => _ReceivedRequestState();
}

class _ReceivedRequestState extends State<ReceivedRequest>
    with SingleTickerProviderStateMixin {
  static const String _auditPrefSearch = 'admin_audit_search';
  static const String _auditPrefAction = 'admin_audit_action';
  static const String _auditPrefAdmin = 'admin_audit_admin';
  static const String _auditPrefTargetType = 'admin_audit_target_type';
  static const String _auditPrefDate = 'admin_audit_date';
  static const String _auditPrefSortBy = 'admin_audit_sort_by';
  static const String _auditPrefSortAsc = 'admin_audit_sort_asc';
  static const String _auditPrefPreset = 'admin_audit_preset';
  static const String _auditPrefTrendThreshold = 'admin_audit_trend_threshold';
  static const String _auditPrefCustomStart = 'admin_audit_custom_start';
  static const String _auditPrefCustomEnd = 'admin_audit_custom_end';

  late TabController _tabController;
  late TailleurRequestController _tailleurRequestController;
  late ModeleService _modeleService;
  late CommandeService _commandeService;
  late UserService _userService;
  late Future<bool> _adminAccessFuture;
  final TextEditingController _broadcastTitleController =
      TextEditingController();
  final TextEditingController _broadcastBodyController =
      TextEditingController();
  final TextEditingController _auditSearchController = TextEditingController();
  bool _isBroadcastSending = false;
  String _broadcastAudience = 'all';
  String _auditActionFilter = 'all';
  String _auditAdminFilter = 'all';
  String _auditTargetTypeFilter = 'all';
  String _auditDateFilter = 'all';
  String _auditSortBy = 'date';
  bool _auditSortAsc = false;
  String _auditPreset = 'all';
  int _auditTrendThreshold = 30;
  DateTimeRange? _auditCustomRange;
  int _auditVisibleCount = 25;

  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tailleurRequestController = Get.put(TailleurRequestController());
    _modeleService = Get.put(ModeleService());
    _commandeService = CommandeService();
    _userService = UserService();
    _adminAccessFuture = _tailleurRequestController.isCurrentUserAdmin();
    _loadAuditPreferences();
  }

  @override
  void dispose() {
    _broadcastTitleController.dispose();
    _broadcastBodyController.dispose();
    _auditSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<bool>(
      future: _adminAccessFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != true) {
          return Scaffold(
            appBar: AppBar(title: const Text('Console admin')),
            body: _buildUnauthorizedState(theme),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Console admin'),
            bottom: TabBar(
              isScrollable: true,
              controller: _tabController,
              labelColor: theme.colorScheme.onSurface,
              unselectedLabelColor:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              indicatorColor: theme.colorScheme.primary,
              labelStyle: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: AppTypography.titleSmall,
              tabs: const [
                Tab(text: 'Aperçu'),
                Tab(text: 'Demandes'),
                Tab(text: 'Utilisateurs'),
                Tab(text: 'Commandes'),
                Tab(text: 'Modèles'),
                Tab(text: 'Diffusion'),
                Tab(text: 'Audit'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildRequestsTab(_tailleurRequestController),
              _buildUsersTab(),
              _buildOrdersTab(),
              _buildUnapprovedModelsTab(_modeleService),
              _buildBroadcastTab(),
              _buildAuditTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _userService.getAllUsers(),
      builder: (context, usersSnapshot) {
        final theme = Theme.of(context);
        if (usersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = usersSnapshot.data ?? <UserModel>[];
        final tailors = users.where((u) => u.isTailleur).length;
        final clients = users.length - tailors;

        return StreamBuilder<List<Commande>>(
          stream: _commandeService.getAllCommandeForAdmin(),
          builder: (context, commandesSnapshot) {
            final commandes = commandesSnapshot.data ?? <Commande>[];
            final acceptedOrders =
                commandes.where((order) => order.isAccepted).length;
            final pendingOrders = commandes.length - acceptedOrders;
            final completionRate = commandes.isEmpty
                ? 0
                : ((acceptedOrders / commandes.length) * 100).round();

            return StreamBuilder<List<TailleurRequest>>(
              stream:
                  _tailleurRequestController.getRequestsByApprovalStatus(false),
              builder: (context, requestsSnapshot) {
                final pendingRequests =
                    (requestsSnapshot.data ?? <TailleurRequest>[]).length;

                return StreamBuilder<List<Modele>>(
                  stream: _modeleService.getUnapprovedModels(),
                  builder: (context, modelsSnapshot) {
                    final pendingModels =
                        (modelsSnapshot.data ?? <Modele>[]).length;

                    return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _tailleurRequestController.getRecentAuditLogs(
                          limit: 300),
                      builder: (context, auditSnapshot) {
                        final timelinePoints = _buildAuditLast7DaysPoints(
                            auditSnapshot.data ?? []);
                        final auditComparison = _buildAudit7DaysComparison(
                            auditSnapshot.data ?? []);
                        final topActions = _buildTopAuditActionsForLast7Days(
                          auditSnapshot.data ?? [],
                          limit: 3,
                        );

                        return ListView(
                          padding: AppSpacing.pagePadding,
                          children: [
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _buildMetricCard(
                                  theme,
                                  title: 'Utilisateurs',
                                  value: '${users.length}',
                                  subtitle:
                                      '$clients clients • $tailors tailleurs',
                                  icon: Icons.people_outline,
                                ),
                                _buildMetricCard(
                                  theme,
                                  title: 'Commandes',
                                  value: '${commandes.length}',
                                  subtitle:
                                      '$acceptedOrders acceptées • $pendingOrders en cours',
                                  icon: Icons.content_cut_outlined,
                                ),
                                _buildMetricCard(
                                  theme,
                                  title: 'Taux de validation',
                                  value: '$completionRate%',
                                  subtitle: 'Part des commandes acceptées',
                                  icon: Icons.insights_outlined,
                                ),
                                _buildMetricCard(
                                  theme,
                                  title: 'Demandes tailleur',
                                  value: '$pendingRequests',
                                  subtitle: 'En attente',
                                  icon: Icons.pending_actions_outlined,
                                ),
                                _buildMetricCard(
                                  theme,
                                  title: 'Modèles à modérer',
                                  value: '$pendingModels',
                                  subtitle: 'Validation requise',
                                  icon: Icons.verified_outlined,
                                ),
                              ],
                            ),
                            AppSpacing.gapV12,
                            _buildAuditTimelineCard(
                              theme,
                              timelinePoints,
                              topActions: topActions,
                              onTopActionTap: _openAuditForAction,
                              previousTotal:
                                  auditComparison['previousTotal'] as int,
                              evolutionPercent:
                                  auditComparison['evolutionPercent']
                                      as double?,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUnauthorizedState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Container(
          padding: AppSpacing.paddingAllLg,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 40,
                color: theme.colorScheme.error,
              ),
              AppSpacing.gapV12,
              Text(
                'Accès réservé aux administrateurs',
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsTab(
      TailleurRequestController tailleurRequestController) {
    return StreamBuilder<List<TailleurRequest>>(
      stream: tailleurRequestController.getRequestsByApprovalStatus(false),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? <TailleurRequest>[];

        if (requests.isEmpty) {
          return Center(
            child: Text(
              'Aucune demande en attente',
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: AppSpacing.pagePadding,
          itemCount: requests.length,
          separatorBuilder: (_, __) => AppSpacing.gapV8,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.16),
                ),
              ),
              child: ExpansionTile(
                title: Text(
                  request.nomAtelier,
                  style: AppTypography.titleSmall.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${request.ville}, ${request.pays}',
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  FutureBuilder<UserModel>(
                    future: UserService().getUser(request.userId),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        );
                      }
                      final user = userSnapshot.data;
                      if (user == null || (user.id ?? '').isEmpty) {
                        return Text(
                          'Utilisateur introuvable',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nomPrenom ?? 'Sans nom',
                            style: AppTypography.titleSmall.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.gapV4,
                          Text(
                            'Téléphone: ${user.phoneNumber ?? '-'}',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.gapV4,
                          Text(
                            'Client cible: ${request.clientCible} • Quartier: ${request.quartier}',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.gapV4,
                          Text(
                            'Travailleurs: ${request.nombreTravailleur} • N° d\'atelier: ${request.numAtelier}',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.gapV12,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final phone = (user.phoneNumber ?? '').trim();
                                  if (phone.isEmpty) {
                                    showCustomSnackbar(
                                      message:
                                          'Numéro de téléphone indisponible',
                                    );
                                    return;
                                  }
                                  final uri = Uri.parse('tel:$phone');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                icon: const Icon(Icons.call_outlined),
                                label: const Text('Appeler'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await tailleurRequestController
                                      .rejectAndDeleteRequest(request);
                                  showCustomSnackbar(
                                    message: 'Demande refusée',
                                    backgroundColor: Colors.orange,
                                  );
                                },
                                child: const Text('Refuser'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await tailleurRequestController
                                      .approveRequest(request);
                                  showCustomSnackbar(
                                    message: 'Demande approuvée',
                                    backgroundColor: Colors.green,
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Approuver'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _userService.getAllUsers(),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data ?? <UserModel>[];

        if (users.isEmpty) {
          return Center(
            child: Text(
              'Aucun utilisateur',
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: AppSpacing.pagePadding,
          itemCount: users.length,
          separatorBuilder: (_, __) => AppSpacing.gapV8,
          itemBuilder: (context, index) {
            final account = users[index];
            return Container(
              padding: AppSpacing.paddingAllMd,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.nomPrenom ?? 'Sans nom',
                    style: AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Téléphone: ${account.phoneNumber ?? '-'}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Email: ${(account.email ?? '').isEmpty ? '-' : account.email}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Rôle: ${appUserRoleToString(account.role)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Adresse: ${(account.adress ?? '').isEmpty ? '-' : account.adress}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapV12,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        await _tailleurRequestController
                            .updateUserTailleurStatus(
                          account,
                          !account.isTailleur,
                        );
                        showCustomSnackbar(
                          message: account.isTailleur
                              ? 'Compte retiré des tailleurs'
                              : 'Compte promu en tailleur',
                        );
                      },
                      icon: const Icon(Icons.manage_accounts_outlined),
                      label: Text(
                        account.isTailleur
                            ? 'Retirer le rôle tailleur'
                            : 'Promouvoir en tailleur',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return StreamBuilder<List<Commande>>(
      stream: _commandeService.getAllCommandeForAdmin(),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? <Commande>[];
        if (orders.isEmpty) {
          return Center(
            child: Text(
              'Aucune commande',
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: AppSpacing.pagePadding,
          itemCount: orders.length,
          separatorBuilder: (_, __) => AppSpacing.gapV8,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              padding: AppSpacing.paddingAllMd,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.nomClient.isEmpty
                        ? 'Client non renseigné'
                        : order.nomClient,
                    style: AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Prix: ${order.prix} FCFA • Statut: ${order.etatLibelle}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Prévue: ${_formatDate(order.datePrevue)} • Ajout: ${_formatDate(order.dateAjout)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'ID tailleur: ${order.idTailleur} • ID client: ${(order.idUser).isEmpty ? '-' : order.idUser}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBroadcastTab() {
    final theme = Theme.of(context);
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        Container(
          padding: AppSpacing.paddingAllMd,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diffuser une notification',
                style: AppTypography.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.gapV12,
              DropdownButtonFormField<String>(
                initialValue: _broadcastAudience,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tous')),
                  DropdownMenuItem(value: 'tailors', child: Text('Tailleurs')),
                  DropdownMenuItem(value: 'clients', child: Text('Clients')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _broadcastAudience = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Audience',
                ),
              ),
              AppSpacing.gapV12,
              TextField(
                controller: _broadcastTitleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                ),
              ),
              AppSpacing.gapV12,
              TextField(
                controller: _broadcastBodyController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                ),
              ),
              AppSpacing.gapV16,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isBroadcastSending ? null : _sendBroadcast,
                  icon: _isBroadcastSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.campaign_outlined),
                  label: Text(
                    _isBroadcastSending
                        ? 'Envoi...'
                        : 'Envoyer la notification',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _tailleurRequestController.getRecentAuditLogs(limit: 150),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data ?? <Map<String, dynamic>>[];
        if (logs.isEmpty) {
          return Center(
            child: Text(
              'Aucune action administrateur enregistrée',
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final actionOptions = logs
            .map((entry) => (entry['action'] ?? '').toString().trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        final effectiveAuditActionFilter = _auditActionFilter == 'all' ||
                actionOptions.contains(_auditActionFilter)
            ? _auditActionFilter
            : 'all';

        final adminOptions = logs
            .map((entry) => (entry['adminId'] ?? '').toString().trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        final effectiveAuditAdminFilter = _auditAdminFilter == 'all' ||
                adminOptions.contains(_auditAdminFilter)
            ? _auditAdminFilter
            : 'all';

        final targetTypeOptions = logs
            .map((entry) => (entry['targetType'] ?? '').toString().trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        final effectiveAuditTargetTypeFilter =
            _auditTargetTypeFilter == 'all' ||
                    targetTypeOptions.contains(_auditTargetTypeFilter)
                ? _auditTargetTypeFilter
                : 'all';
        final effectiveAuditDateFilter =
            _auditDateFilter == 'custom' && _auditCustomRange == null
                ? 'all'
                : _auditDateFilter;

        final securityCount = logs.where((entry) {
          return _matchesAuditPresetFor(
            'security',
            action: (entry['action'] ?? '').toString(),
            targetType: (entry['targetType'] ?? '').toString(),
          );
        }).length;
        final operationsCount = logs.where((entry) {
          return _matchesAuditPresetFor(
            'operations',
            action: (entry['action'] ?? '').toString(),
            targetType: (entry['targetType'] ?? '').toString(),
          );
        }).length;
        final moderationCount = logs.where((entry) {
          return _matchesAuditPresetFor(
            'moderation',
            action: (entry['action'] ?? '').toString(),
            targetType: (entry['targetType'] ?? '').toString(),
          );
        }).length;

        final query = _auditSearchController.text.trim().toLowerCase();
        final filteredLogs = logs.where((entry) {
          final action = (entry['action'] ?? '').toString();
          final targetType = (entry['targetType'] ?? '').toString();
          final targetId = (entry['targetId'] ?? '').toString();
          final adminId = (entry['adminId'] ?? '').toString();
          final createdAtDate = _extractAuditDate(entry);

          final matchesAction = effectiveAuditActionFilter == 'all' ||
              action == effectiveAuditActionFilter;
          final matchesAdmin = effectiveAuditAdminFilter == 'all' ||
              adminId == effectiveAuditAdminFilter;
          final matchesTargetType = effectiveAuditTargetTypeFilter == 'all' ||
              targetType == effectiveAuditTargetTypeFilter;
          final matchesDate = _matchesAuditDateFilter(createdAtDate);
          final matchesPreset = _matchesAuditPreset(
            action: action,
            targetType: targetType,
          );
          final searchable =
              '$action $targetType $targetId $adminId'.toLowerCase();
          final matchesSearch = query.isEmpty || searchable.contains(query);

          return matchesAction &&
              matchesAdmin &&
              matchesTargetType &&
              matchesDate &&
              matchesPreset &&
              matchesSearch;
        }).toList();

        filteredLogs.sort((a, b) {
          int comparison;
          switch (_auditSortBy) {
            case 'action':
              comparison = (a['action'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo((b['action'] ?? '').toString().toLowerCase());
              break;
            case 'admin':
              comparison = (a['adminId'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo((b['adminId'] ?? '').toString().toLowerCase());
              break;
            case 'targetType':
              comparison = (a['targetType'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo((b['targetType'] ?? '').toString().toLowerCase());
              break;
            case 'date':
            default:
              final dateA = _extractAuditDate(a) ?? DateTime(1970);
              final dateB = _extractAuditDate(b) ?? DateTime(1970);
              comparison = dateA.compareTo(dateB);
              break;
          }
          return _auditSortAsc ? comparison : -comparison;
        });

        final visibleCount = _auditVisibleCount > filteredLogs.length
            ? filteredLogs.length
            : _auditVisibleCount;
        final visibleLogs = filteredLogs.take(visibleCount).toList();
        final hasMore = visibleCount < filteredLogs.length;

        return ListView(
          padding: AppSpacing.pagePadding,
          children: [
            Container(
              padding: AppSpacing.paddingAllMd,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Tooltip(
                      message: 'Revenir à l’aperçu',
                      child: ActionChip(
                        avatar: const Icon(Icons.dashboard_outlined, size: 16),
                        label: const Text('Revenir à l’aperçu'),
                        onPressed: () {
                          _tabController.animateTo(0);
                        },
                      ),
                    ),
                  ),
                  AppSpacing.gapV8,
                  TextField(
                    controller: _auditSearchController,
                    onChanged: (_) {
                      setState(() {
                        _auditVisibleCount = 25;
                      });
                      _saveAuditPreferences();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Rechercher (action, cible, admin)',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  if (effectiveAuditActionFilter != 'all' ||
                      effectiveAuditAdminFilter != 'all' ||
                      effectiveAuditTargetTypeFilter != 'all' ||
                      effectiveAuditDateFilter != 'all') ...[
                    AppSpacing.gapV8,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Tooltip(
                        message: 'Effacer les filtres actifs',
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _auditActionFilter = 'all';
                              _auditAdminFilter = 'all';
                              _auditTargetTypeFilter = 'all';
                              _auditDateFilter = 'all';
                              _auditCustomRange = null;
                              _auditVisibleCount = 25;
                            });
                            _saveAuditPreferences();
                          },
                          icon: const Icon(Icons.filter_alt_off_outlined),
                          label: const Text('Effacer les filtres actifs'),
                        ),
                      ),
                    ),
                    AppSpacing.gapV4,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (effectiveAuditActionFilter != 'all')
                          InputChip(
                            avatar: const Icon(
                              Icons.filter_alt_outlined,
                              size: 16,
                            ),
                            label: Text('Action: $effectiveAuditActionFilter'),
                            onDeleted: () {
                              setState(() {
                                _auditActionFilter = 'all';
                                _auditVisibleCount = 25;
                              });
                              _saveAuditPreferences();
                            },
                          ),
                        if (effectiveAuditAdminFilter != 'all')
                          InputChip(
                            avatar: const Icon(
                              Icons.filter_alt_outlined,
                              size: 16,
                            ),
                            label: Text('Admin: $effectiveAuditAdminFilter'),
                            onDeleted: () {
                              setState(() {
                                _auditAdminFilter = 'all';
                                _auditVisibleCount = 25;
                              });
                              _saveAuditPreferences();
                            },
                          ),
                        if (effectiveAuditTargetTypeFilter != 'all')
                          InputChip(
                            avatar: const Icon(
                              Icons.filter_alt_outlined,
                              size: 16,
                            ),
                            label: Text(
                              'Type: $effectiveAuditTargetTypeFilter',
                            ),
                            onDeleted: () {
                              setState(() {
                                _auditTargetTypeFilter = 'all';
                                _auditVisibleCount = 25;
                              });
                              _saveAuditPreferences();
                            },
                          ),
                        if (effectiveAuditDateFilter != 'all')
                          InputChip(
                            avatar: const Icon(
                              Icons.filter_alt_outlined,
                              size: 16,
                            ),
                            label: Text(
                              effectiveAuditDateFilter == 'custom' &&
                                      _auditCustomRange != null
                                  ? 'Date: ${_formatDate(_auditCustomRange!.start)} → ${_formatDate(_auditCustomRange!.end)}'
                                  : (effectiveAuditDateFilter == '7d'
                                      ? 'Date: 7 derniers jours'
                                      : (effectiveAuditDateFilter == '30d'
                                          ? 'Date: 30 derniers jours'
                                          : 'Date: ${effectiveAuditDateFilter.toUpperCase()}')),
                            ),
                            onDeleted: () {
                              setState(() {
                                _auditDateFilter = 'all';
                                _auditCustomRange = null;
                                _auditVisibleCount = 25;
                              });
                              _saveAuditPreferences();
                            },
                          ),
                      ],
                    ),
                  ],
                  AppSpacing.gapV12,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text('Tous (${logs.length})'),
                        selected: _auditPreset == 'all',
                        onSelected: (_) => _applyAuditPreset('all'),
                      ),
                      ChoiceChip(
                        label: Text('Sécurité ($securityCount)'),
                        selected: _auditPreset == 'security',
                        onSelected: (_) => _applyAuditPreset('security'),
                      ),
                      ChoiceChip(
                        label: Text('Opérations ($operationsCount)'),
                        selected: _auditPreset == 'operations',
                        onSelected: (_) => _applyAuditPreset('operations'),
                      ),
                      ChoiceChip(
                        label: Text('Modération ($moderationCount)'),
                        selected: _auditPreset == 'moderation',
                        onSelected: (_) => _applyAuditPreset('moderation'),
                      ),
                    ],
                  ),
                  AppSpacing.gapV12,
                  DropdownButtonFormField<String>(
                    initialValue: effectiveAuditActionFilter,
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('Toutes les actions'),
                      ),
                      ...actionOptions.map(
                        (action) => DropdownMenuItem<String>(
                          value: action,
                          child: Text(action),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _auditActionFilter = value;
                        _auditVisibleCount = 25;
                      });
                      _saveAuditPreferences();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par action',
                    ),
                  ),
                  AppSpacing.gapV12,
                  DropdownButtonFormField<String>(
                    initialValue: effectiveAuditAdminFilter,
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('Tous les admins'),
                      ),
                      ...adminOptions.map(
                        (adminId) => DropdownMenuItem<String>(
                          value: adminId,
                          child: Text(adminId),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _auditAdminFilter = value;
                        _auditVisibleCount = 25;
                      });
                      _saveAuditPreferences();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par admin',
                    ),
                  ),
                  AppSpacing.gapV12,
                  DropdownButtonFormField<String>(
                    initialValue: effectiveAuditTargetTypeFilter,
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('Tous les types de cible'),
                      ),
                      ...targetTypeOptions.map(
                        (targetType) => DropdownMenuItem<String>(
                          value: targetType,
                          child: Text(targetType),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _auditTargetTypeFilter = value;
                        _auditVisibleCount = 25;
                      });
                      _saveAuditPreferences();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par type de cible',
                    ),
                  ),
                  AppSpacing.gapV12,
                  DropdownButtonFormField<String>(
                    initialValue: effectiveAuditDateFilter,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('Toutes les dates'),
                      ),
                      DropdownMenuItem<String>(
                        value: '7d',
                        child: Text('7 derniers jours'),
                      ),
                      DropdownMenuItem<String>(
                        value: '30d',
                        child: Text('30 derniers jours'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'custom',
                        child: Text('Plage personnalisée'),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        _auditDateFilter = value;
                        _auditVisibleCount = 25;
                      });
                      _saveAuditPreferences();
                      if (value == 'custom' && mounted) {
                        await _pickAuditDateRange();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par date',
                    ),
                  ),
                  if (_auditDateFilter == 'custom') ...[
                    AppSpacing.gapV8,
                    OutlinedButton.icon(
                      onPressed: _pickAuditDateRange,
                      icon: const Icon(Icons.date_range_outlined),
                      label: Text(
                        _auditCustomRange == null
                            ? 'Choisir la plage'
                            : '${_formatDate(_auditCustomRange!.start)} → ${_formatDate(_auditCustomRange!.end)}',
                      ),
                    ),
                  ],
                  AppSpacing.gapV12,
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _auditSortBy,
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'date',
                              child: Text('Tri: Date'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'action',
                              child: Text('Tri: Action'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'admin',
                              child: Text('Tri: Admin'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'targetType',
                              child: Text('Tri: Type cible'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _auditSortBy = value;
                            });
                            _saveAuditPreferences();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Ordre de tri',
                          ),
                        ),
                      ),
                      AppSpacing.gapH8,
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _auditSortAsc = !_auditSortAsc;
                          });
                          _saveAuditPreferences();
                        },
                        icon: Icon(
                          _auditSortAsc
                              ? Icons.arrow_upward_outlined
                              : Icons.arrow_downward_outlined,
                        ),
                        tooltip:
                            _auditSortAsc ? 'Tri croissant' : 'Tri décroissant',
                      ),
                    ],
                  ),
                  AppSpacing.gapV8,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Résultats: ${filteredLogs.length}',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: filteredLogs.isEmpty
                            ? null
                            : () => _exportAuditCsv(filteredLogs),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Exporter CSV'),
                      ),
                    ],
                  ),
                  AppSpacing.gapV8,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _auditSearchController.clear();
                          _auditActionFilter = 'all';
                          _auditAdminFilter = 'all';
                          _auditTargetTypeFilter = 'all';
                          _auditDateFilter = 'all';
                          _auditCustomRange = null;
                          _auditSortBy = 'date';
                          _auditSortAsc = false;
                          _auditPreset = 'all';
                          _auditVisibleCount = 25;
                        });
                        _saveAuditPreferences();
                      },
                      icon: const Icon(Icons.restart_alt_outlined),
                      label: const Text('Réinitialiser les filtres'),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapV8,
            if (filteredLogs.isEmpty)
              Padding(
                padding: AppSpacing.paddingAllMd,
                child: Text(
                  'Aucun log ne correspond aux filtres',
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ...List.generate(visibleLogs.length, (index) {
              final entry = visibleLogs[index];
              final action = (entry['action'] ?? '').toString();
              final targetType = (entry['targetType'] ?? '').toString();
              final targetId = (entry['targetId'] ?? '').toString();
              final adminId = (entry['adminId'] ?? '').toString();
              final createdAtDate = _extractAuditDate(entry);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == visibleLogs.length - 1 ? 0 : 8,
                ),
                child: Container(
                  padding: AppSpacing.paddingAllMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action,
                        style: AppTypography.titleSmall.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.gapV4,
                      Text(
                        'Cible: $targetType • ID: ${targetId.isEmpty ? '-' : targetId}',
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.gapV4,
                      Text(
                        'Admin: ${adminId.isEmpty ? '-' : adminId}',
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.gapV4,
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          OutlinedButton.icon(
                            onPressed: targetId.isEmpty
                                ? null
                                : () => _copyAuditValue(
                                      label: 'ID cible',
                                      value: targetId,
                                    ),
                            icon: const Icon(Icons.copy_outlined, size: 16),
                            label: const Text('Copier ID cible'),
                          ),
                          OutlinedButton.icon(
                            onPressed: adminId.isEmpty
                                ? null
                                : () => _copyAuditValue(
                                      label: 'ID admin',
                                      value: adminId,
                                    ),
                            icon: const Icon(Icons.copy_outlined, size: 16),
                            label: const Text('Copier ID admin'),
                          ),
                        ],
                      ),
                      if (createdAtDate != null) ...[
                        AppSpacing.gapV4,
                        Text(
                          'Date: ${_formatDate(createdAtDate)} ${createdAtDate.hour.toString().padLeft(2, '0')}:${createdAtDate.minute.toString().padLeft(2, '0')}',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            if (hasMore) ...[
              AppSpacing.gapV8,
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _auditVisibleCount += 25;
                    });
                  },
                  icon: const Icon(Icons.expand_more),
                  label: const Text('Charger plus'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          AppSpacing.gapV8,
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapV4,
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.gapV4,
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildAuditLast7DaysPoints(
    List<Map<String, dynamic>> logs,
  ) {
    final now = DateTime.now();
    final points = List.generate(7, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      return {
        'date': day,
        'label':
            '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}',
        'count': 0,
      };
    });

    for (final log in logs) {
      final createdAt = _extractAuditDate(log);
      if (createdAt == null) continue;

      final normalized =
          DateTime(createdAt.year, createdAt.month, createdAt.day);
      for (final point in points) {
        if (point['date'] == normalized) {
          point['count'] = (point['count'] as int) + 1;
          break;
        }
      }
    }

    return points;
  }

  Map<String, dynamic> _buildAudit7DaysComparison(
    List<Map<String, dynamic>> logs,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentStart = today.subtract(const Duration(days: 6));
    final previousStart = currentStart.subtract(const Duration(days: 7));
    final previousEnd = currentStart.subtract(const Duration(days: 1));

    int currentTotal = 0;
    int previousTotal = 0;

    for (final log in logs) {
      final createdAt = _extractAuditDate(log);
      if (createdAt == null) continue;
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);

      if (!day.isBefore(currentStart) && !day.isAfter(today)) {
        currentTotal++;
      } else if (!day.isBefore(previousStart) && !day.isAfter(previousEnd)) {
        previousTotal++;
      }
    }

    double? evolutionPercent;
    if (previousTotal > 0) {
      evolutionPercent =
          ((currentTotal - previousTotal) / previousTotal.toDouble()) * 100;
    } else if (currentTotal > 0) {
      evolutionPercent = 100;
    }

    return {
      'currentTotal': currentTotal,
      'previousTotal': previousTotal,
      'evolutionPercent': evolutionPercent,
    };
  }

  List<Map<String, dynamic>> _buildTopAuditActionsForLast7Days(
    List<Map<String, dynamic>> logs, {
    int limit = 3,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final counts = <String, int>{};

    for (final log in logs) {
      final createdAt = _extractAuditDate(log);
      if (createdAt == null) continue;

      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      if (day.isBefore(start) || day.isAfter(today)) continue;

      final action = (log['action'] ?? '').toString().trim();
      if (action.isEmpty) continue;

      counts[action] = (counts[action] ?? 0) + 1;
    }

    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });

    return entries
        .take(limit)
        .map(
          (entry) => {
            'action': entry.key,
            'count': entry.value,
          },
        )
        .toList();
  }

  Widget _buildAuditTimelineCard(
    ThemeData theme,
    List<Map<String, dynamic>> points, {
    required List<Map<String, dynamic>> topActions,
    required ValueChanged<String> onTopActionTap,
    required int previousTotal,
    required double? evolutionPercent,
  }) {
    final maxCount = points
        .map((point) => point['count'] as int)
        .fold<int>(1, (current, next) => next > current ? next : current);
    final total =
        points.fold<int>(0, (total, point) => total + (point['count'] as int));
    final isUp = (evolutionPercent ?? 0) >= 0;
    final trendColor = isUp ? Colors.green : theme.colorScheme.error;
    final trendAlert = _buildAuditTrendAlert(
      evolutionPercent: evolutionPercent,
      previousTotal: previousTotal,
      total: total,
    );
    const thresholdChoices = <int>[10, 20, 30, 50];

    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activité audit (7 derniers jours)',
            style: AppTypography.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapV4,
          Text(
            '$total actions enregistrées',
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapV4,
          Row(
            children: [
              Text(
                '7j précédents: $previousTotal',
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapH8,
              if (evolutionPercent != null)
                Text(
                  '${isUp ? '↗' : '↘'} ${evolutionPercent.abs().toStringAsFixed(1)}%',
                  style: AppTypography.bodySmall.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          AppSpacing.gapV8,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: thresholdChoices.map((threshold) {
              return ChoiceChip(
                label: Text('Seuil $threshold%'),
                selected: _auditTrendThreshold == threshold,
                onSelected: (_) {
                  setState(() {
                    _auditTrendThreshold = threshold;
                  });
                  _saveAuditPreferences();
                },
              );
            }).toList(),
          ),
          if (trendAlert != null) ...[
            AppSpacing.gapV8,
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingAllMd,
              decoration: BoxDecoration(
                color: (trendAlert['color'] as Color).withValues(alpha: 0.12),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: (trendAlert['color'] as Color).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    trendAlert['icon'] as IconData,
                    color: trendAlert['color'] as Color,
                    size: 18,
                  ),
                  AppSpacing.gapH8,
                  Expanded(
                    child: Text(
                      trendAlert['message'] as String,
                      style: AppTypography.bodySmall.copyWith(
                        color: trendAlert['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (topActions.isNotEmpty) ...[
            AppSpacing.gapV12,
            Text(
              'Top actions (7 jours)',
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.gapV8,
            ...topActions.map((entry) {
              final action = (entry['action'] ?? '').toString();
              final count = entry['count'] as int? ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppRadius.radiusSm,
                    onTap: () => onTopActionTap(action),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              action,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.filter_alt_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          AppSpacing.gapH8,
                          Text(
                            '$count',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
          AppSpacing.gapV12,
          SizedBox(
            height: 108,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((point) {
                final count = point['count'] as int;
                final ratio = count / maxCount;
                final barHeight =
                    ratio <= 0 ? 4.0 : (ratio * 72).clamp(4, 72).toDouble();
                final label = point['label'] as String;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.gapV4,
                      Container(
                        width: 16,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      AppSpacing.gapV4,
                      Text(
                        label,
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _openAuditForAction(String action) {
    final normalizedAction = action.trim();
    if (normalizedAction.isEmpty) return;

    setState(() {
      _auditPreset = 'all';
      _auditSearchController.clear();
      _auditActionFilter = normalizedAction;
      _auditAdminFilter = 'all';
      _auditTargetTypeFilter = 'all';
      _auditDateFilter = 'all';
      _auditCustomRange = null;
      _auditSortBy = 'date';
      _auditSortAsc = false;
      _auditVisibleCount = 25;
      _tabController.animateTo(6);
    });
    _saveAuditPreferences();
  }

  Map<String, dynamic>? _buildAuditTrendAlert({
    required double? evolutionPercent,
    required int previousTotal,
    required int total,
  }) {
    final threshold = _auditTrendThreshold;

    if (evolutionPercent == null) {
      if (total >= 20 && previousTotal == 0) {
        return {
          'message':
              'Pic d’activité détecté: forte hausse par rapport aux 7 jours précédents.',
          'color': Colors.green,
          'icon': Icons.trending_up_outlined,
        };
      }
      return null;
    }

    if (evolutionPercent >= threshold) {
      return {
        'message':
            'Hausse marquée de l’activité audit (≥ $threshold%). Vérifiez les actions récentes.',
        'color': Colors.green,
        'icon': Icons.trending_up_outlined,
      };
    }

    if (evolutionPercent <= -threshold) {
      return {
        'message':
            'Baisse marquée de l’activité audit (≥ $threshold% de baisse). Contrôlez la couverture des actions.',
        'color': Colors.orange,
        'icon': Icons.trending_down_outlined,
      };
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _sendBroadcast() async {
    final title = _broadcastTitleController.text.trim();
    final body = _broadcastBodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      showCustomSnackbar(message: 'Veuillez saisir un titre et un message');
      return;
    }

    setState(() {
      _isBroadcastSending = true;
    });

    try {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('users');
      if (_broadcastAudience == 'tailors') {
        query = query.where('isTailleur', isEqualTo: true);
      } else if (_broadcastAudience == 'clients') {
        query = query.where('isTailleur', isEqualTo: false);
      }

      final snapshot = await query.get();
      int sent = 0;
      for (final doc in snapshot.docs) {
        final token = (doc.data()['token'] ?? '').toString().trim();
        if (token.isEmpty) continue;
        await sendNotification(token, title, body);
        sent++;
      }

      showCustomSnackbar(
        message: 'Notification envoyée à $sent compte(s)',
        backgroundColor: Colors.green,
      );
      await _tailleurRequestController.logBroadcast(
        audience: _broadcastAudience,
        title: title,
        recipientCount: sent,
      );
      _broadcastTitleController.clear();
      _broadcastBodyController.clear();
    } catch (_) {
      showCustomSnackbar(message: 'Erreur lors de la diffusion');
    } finally {
      if (mounted) {
        setState(() {
          _isBroadcastSending = false;
        });
      }
    }
  }

  Widget _buildUnapprovedModelsTab(ModeleService modeleService) {
    return StreamBuilder<List<Modele>>(
      stream: modeleService.getUnapprovedModels(),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final models = snapshot.data ?? <Modele>[];

        if (models.isEmpty) {
          return Center(
            child: Text(
              'Aucun modèle en attente de validation',
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: AppSpacing.pagePadding,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.72,
          ),
          itemCount: models.length,
          itemBuilder: (context, index) {
            final model = models[index];
            final mediaUrl =
                model.fichier.isNotEmpty ? (model.fichier.first ?? '') : '';
            return InkWell(
              onTap: () {
                Get.to(() => DetailModeleView(model));
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: mediaUrl.isEmpty
                          ? Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : Image.network(
                              mediaUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                        color: Colors.black.withValues(alpha: 0.5),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _tailleurRequestController.rejectModel(model);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  side: const BorderSide(color: Colors.white70),
                                ),
                                child: const Text(
                                  'Refuser',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            AppSpacing.gapH8,
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _tailleurRequestController
                                      .approveModel(model);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                ),
                                child: const Text('Approuver'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  DateTime? _extractAuditDate(Map<String, dynamic> entry) {
    final raw = entry['createdAt'];
    if (raw is Timestamp) return raw.toDate();
    return null;
  }

  bool _matchesAuditDateFilter(DateTime? date) {
    if (_auditDateFilter == 'all') return true;
    if (date == null) return false;

    final now = DateTime.now();
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (_auditDateFilter == '7d') {
      final threshold = now.subtract(const Duration(days: 7));
      return normalizedDate.isAfter(
            DateTime(threshold.year, threshold.month, threshold.day)
                .subtract(const Duration(days: 1)),
          ) &&
          !normalizedDate.isAfter(DateTime(now.year, now.month, now.day));
    }

    if (_auditDateFilter == '30d') {
      final threshold = now.subtract(const Duration(days: 30));
      return normalizedDate.isAfter(
            DateTime(threshold.year, threshold.month, threshold.day)
                .subtract(const Duration(days: 1)),
          ) &&
          !normalizedDate.isAfter(DateTime(now.year, now.month, now.day));
    }

    if (_auditDateFilter == 'custom') {
      final range = _auditCustomRange;
      if (range == null) return false;
      final start =
          DateTime(range.start.year, range.start.month, range.start.day);
      final end = DateTime(range.end.year, range.end.month, range.end.day);
      return !normalizedDate.isBefore(start) && !normalizedDate.isAfter(end);
    }

    return true;
  }

  bool _matchesAuditPreset({
    required String action,
    required String targetType,
  }) {
    return _matchesAuditPresetFor(
      _auditPreset,
      action: action,
      targetType: targetType,
    );
  }

  bool _matchesAuditPresetFor(
    String preset, {
    required String action,
    required String targetType,
  }) {
    if (preset == 'all') return true;

    final actionLower = action.toLowerCase();
    final targetLower = targetType.toLowerCase();

    if (preset == 'moderation') {
      return targetLower.contains('modele') || actionLower.contains('model');
    }

    if (preset == 'operations') {
      return targetLower.contains('broadcast') ||
          targetLower.contains('commande') ||
          targetLower.contains('tailorrequest') ||
          actionLower.contains('broadcast') ||
          actionLower.contains('approve_tailor_request') ||
          actionLower.contains('reject_tailor_request');
    }

    if (preset == 'security') {
      return targetLower.contains('user') ||
          actionLower.contains('promote') ||
          actionLower.contains('demote') ||
          actionLower.contains('admin');
    }

    return true;
  }

  void _applyAuditPreset(String preset) {
    setState(() {
      _auditPreset = preset;
      _auditVisibleCount = 25;
      if (preset == 'all') {
        return;
      }

      _auditActionFilter = 'all';
      _auditAdminFilter = 'all';
      _auditTargetTypeFilter = 'all';
      _auditDateFilter = 'all';
      _auditCustomRange = null;
      _auditSortBy = 'date';
      _auditSortAsc = false;
    });
    _saveAuditPreferences();
  }

  Future<void> _pickAuditDateRange() async {
    final now = DateTime.now();
    final initial = _auditCustomRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initial,
      helpText: 'Sélectionner une plage',
      saveText: 'Appliquer',
    );

    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _auditCustomRange = picked;
      _auditVisibleCount = 25;
    });
    _saveAuditPreferences();
  }

  Future<void> _loadAuditPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDateFilter = prefs.getString(_auditPrefDate) ?? 'all';
    final startMs = prefs.getInt(_auditPrefCustomStart);
    final endMs = prefs.getInt(_auditPrefCustomEnd);

    DateTimeRange? storedRange;
    if (startMs != null && endMs != null) {
      final start = DateTime.fromMillisecondsSinceEpoch(startMs);
      final end = DateTime.fromMillisecondsSinceEpoch(endMs);
      if (!end.isBefore(start)) {
        storedRange = DateTimeRange(start: start, end: end);
      }
    }

    if (!mounted) return;
    setState(() {
      _auditSearchController.text = prefs.getString(_auditPrefSearch) ?? '';
      _auditActionFilter = prefs.getString(_auditPrefAction) ?? 'all';
      _auditAdminFilter = prefs.getString(_auditPrefAdmin) ?? 'all';
      _auditTargetTypeFilter = prefs.getString(_auditPrefTargetType) ?? 'all';
      _auditDateFilter = storedDateFilter == 'custom' && storedRange == null
          ? 'all'
          : storedDateFilter;
      _auditSortBy = prefs.getString(_auditPrefSortBy) ?? 'date';
      _auditSortAsc = prefs.getBool(_auditPrefSortAsc) ?? false;
      _auditPreset = prefs.getString(_auditPrefPreset) ?? 'all';
      final threshold = prefs.getInt(_auditPrefTrendThreshold) ?? 30;
      _auditTrendThreshold =
          [10, 20, 30, 50].contains(threshold) ? threshold : 30;
      _auditCustomRange = storedRange;
      _auditVisibleCount = 25;
    });
  }

  void _saveAuditPreferences() {
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString(_auditPrefSearch, _auditSearchController.text);
      await prefs.setString(_auditPrefAction, _auditActionFilter);
      await prefs.setString(_auditPrefAdmin, _auditAdminFilter);
      await prefs.setString(_auditPrefTargetType, _auditTargetTypeFilter);
      await prefs.setString(_auditPrefDate, _auditDateFilter);
      await prefs.setString(_auditPrefSortBy, _auditSortBy);
      await prefs.setBool(_auditPrefSortAsc, _auditSortAsc);
      await prefs.setString(_auditPrefPreset, _auditPreset);
      await prefs.setInt(_auditPrefTrendThreshold, _auditTrendThreshold);

      final range = _auditCustomRange;
      if (range == null) {
        await prefs.remove(_auditPrefCustomStart);
        await prefs.remove(_auditPrefCustomEnd);
      } else {
        await prefs.setInt(
          _auditPrefCustomStart,
          range.start.millisecondsSinceEpoch,
        );
        await prefs.setInt(
          _auditPrefCustomEnd,
          range.end.millisecondsSinceEpoch,
        );
      }
    });
  }

  Future<void> _exportAuditCsv(List<Map<String, dynamic>> logs) async {
    String escapeCsv(String input) {
      final normalized = input.replaceAll('"', '""').replaceAll('\n', ' ');
      return '"$normalized"';
    }

    final buffer = StringBuffer();
    buffer.writeln('action,targetType,targetId,adminId,createdAt,metadata');
    for (final entry in logs) {
      final action = (entry['action'] ?? '').toString();
      final targetType = (entry['targetType'] ?? '').toString();
      final targetId = (entry['targetId'] ?? '').toString();
      final adminId = (entry['adminId'] ?? '').toString();
      final createdAt = _extractAuditDate(entry)?.toIso8601String() ?? '';
      final metadata = jsonEncode(entry['metadata'] ?? <String, dynamic>{});

      buffer.writeln(
        '${escapeCsv(action)},${escapeCsv(targetType)},${escapeCsv(targetId)},${escapeCsv(adminId)},${escapeCsv(createdAt)},${escapeCsv(metadata)}',
      );
    }

    await Share.share(
      buffer.toString(),
      subject: 'admin-audit-logs.csv',
    );
  }

  Future<void> _copyAuditValue({
    required String label,
    required String value,
  }) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    showCustomSnackbar(
      message: '$label copié',
      backgroundColor: Colors.green,
    );
  }
}
