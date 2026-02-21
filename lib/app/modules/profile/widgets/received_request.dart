import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/tailleur_request.dart';
import 'package:faani/app/data/models/users_model.dart';
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
import 'package:get/get.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TailleurRequestController extends GetxController {
  final TailleurRequestService service = TailleurRequestService();
  final _usersService = UserService();

  Stream<List<TailleurRequest>> getRequestsByApprovalStatus(bool status) {
    return service.getRequestsByApprovalStatus(status);
  }

  Future<bool> isCurrentUserAdmin() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return false;
    final adminDoc =
        await FirebaseFirestore.instance.collection('admin').doc(uid).get();
    return adminDoc.exists;
  }

  Future<void> approveRequest(TailleurRequest request) async {
    if (request.id == null) return;
    await service.updateRequestApprovalStatus(request.id!, true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(request.userId)
        .update({
      'isTailleur': true,
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
  }

  Future<void> rejectAndDeleteRequest(TailleurRequest request) async {
    if (request.id == null) return;
    await service.deleteRequest(request.id!);
  }

  Future<void> updateUserTailleurStatus(UserModel user, bool isTailleur) {
    final uid = user.id;
    if (uid == null || uid.isEmpty) {
      return Future.value();
    }
    return _usersService.updateUserIsTailleur(uid, isTailleur);
  }

  // get request by tailleur id
  Future<TailleurRequest?> getRequest(String userId) async {
    return service.getRequestByUserId(userId);
  }
}

class ReceivedRequest extends StatefulWidget {
  const ReceivedRequest({super.key});

  @override
  _ReceivedRequestState createState() => _ReceivedRequestState();
}

class _ReceivedRequestState extends State<ReceivedRequest>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TailleurRequestController _tailleurRequestController;
  late ModeleService _modeleService;
  late Future<bool> _adminAccessFuture;

  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tailleurRequestController = Get.put(TailleurRequestController());
    _modeleService = Get.put(ModeleService());
    _adminAccessFuture = _tailleurRequestController.isCurrentUserAdmin();
  }

  @override
  void dispose() {
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
            appBar: AppBar(title: const Text('Gestion tailleurs')),
            body: _buildUnauthorizedState(theme),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestion tailleurs'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Demandes'),
                Tab(text: 'Modèles'),
                Tab(text: 'Tailleurs'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsTab(_tailleurRequestController),
              _buildUnapprovedModelsTab(_modeleService),
              _buildTailorsTab(),
            ],
          ),
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
                            'Travailleurs: ${request.nombreTravailleur} • N° atelier: ${request.numAtelier}',
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

  Widget _buildTailorsTab() {
    return StreamBuilder<List<UserModel>>(
      stream: UserService().getAllTailleur(),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final tailors = snapshot.data ?? <UserModel>[];

        if (tailors.isEmpty) {
          return Center(
            child: Text(
              'Aucun tailleur enregistré',
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: AppSpacing.pagePadding,
          itemCount: tailors.length,
          separatorBuilder: (_, __) => AppSpacing.gapV8,
          itemBuilder: (context, index) {
            final tailor = tailors[index];
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
                    tailor.nomPrenom ?? 'Sans nom',
                    style: AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Téléphone: ${tailor.phoneNumber ?? '-'}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Email: ${(tailor.email ?? '').isEmpty ? '-' : tailor.email}',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    'Adresse: ${(tailor.adress ?? '').isEmpty ? '-' : tailor.adress}',
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
                          tailor,
                          !tailor.isTailleur,
                        );
                        showCustomSnackbar(
                          message: tailor.isTailleur
                              ? 'Compte retiré des tailleurs'
                              : 'Compte passé en tailleur',
                        );
                      },
                      icon: const Icon(Icons.manage_accounts_outlined),
                      label: Text(
                        tailor.isTailleur
                            ? 'Retirer Tailleur'
                            : 'Promouvoir Tailleur',
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
                                  if (model.id == null) return;
                                  modeleService.updateModelApprovalStatus(
                                    model.id!,
                                    false,
                                  );
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
                                  if (model.id == null) return;
                                  modeleService.updateModelApprovalStatus(
                                    model.id!,
                                    true,
                                  );
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
}
