import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/views/detail_commande_view.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/services/commande_service.dart';
import 'package:faani/app/domain/order/order_deadline.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'commande_container.dart';

class ListCommande extends StatelessWidget {
  const ListCommande({super.key, required this.status});

  final String status;

  Stream _getStream() {
    switch (status) {
      case 'receive':
        return CommandeService().getAllCommandeByEtat(1);
      case 'finish':
        return CommandeService().getAllCommandeByEtat(0);
      case 'save':
        return CommandeService().getAllCommandeByEtat(2);
      default:
        return const Stream.empty();
    }
  }

  String _getEmptyMessage() {
    switch (status) {
      case 'receive':
        return 'Aucune commande en cours';
      case 'save':
        return 'Aucune commande enregistrée';
      default:
        return 'Aucune commande terminée';
    }
  }

  Future<void> _showDeleteOverlay(BuildContext context) {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer'),
          content: const Text('Cette action n\'est pas encore disponible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CommandeController controller = Get.find<CommandeController>();

    return StreamBuilder(
      stream: _getStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingStateWidget();
        } else if (snapshot.hasError) {
          return ErrorStateWidget(
            message: 'Erreur: ${snapshot.error}',
          );
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          return EmptyStateWidget(
            image: Image.asset('assets/images/no_commande.png'),
            title: _getEmptyMessage(),
            description: 'Les commandes apparaîtront ici',
          );
        } else {
          final commandes = List<Commande>.from(snapshot.data as List<Commande>)
            ..sort((left, right) {
              final leftNeedsResponse = !left.isAccepted ? 0 : 1;
              final rightNeedsResponse = !right.isAccepted ? 0 : 1;
              final responseComparison =
                  leftNeedsResponse.compareTo(rightNeedsResponse);
              if (responseComparison != 0) return responseComparison;
              final leftDeadline = getOrderDeadline(
                expectedDate: left.datePrevue,
                stage: left.stage,
              );
              final rightDeadline = getOrderDeadline(
                expectedDate: right.datePrevue,
                stage: right.stage,
              );
              final deadlineComparison =
                  leftDeadline.priority.compareTo(rightDeadline.priority);
              if (deadlineComparison != 0) return deadlineComparison;
              return left.datePrevue.compareTo(right.datePrevue);
            });
          final overdueCount = commandes
              .where((commande) =>
                  getOrderDeadline(
                    expectedDate: commande.datePrevue,
                    stage: commande.stage,
                  ) ==
                  OrderDeadline.overdue)
              .length;
          final awaitingCount =
              commandes.where((commande) => !commande.isAccepted).length;
          return Column(
            children: [
              _PrioritySummary(
                overdueCount: overdueCount,
                awaitingCount: awaitingCount,
              ),
              Expanded(
                child: GridView.builder(
                  padding: AppSpacing.paddingAllMd,
                  itemCount: commandes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: MediaQuery.sizeOf(context).width /
                        (MediaQuery.sizeOf(context).height / 1.7),
                  ),
                  itemBuilder: (context, index) {
                    final commande = commandes[index];
                    final deadline = getOrderDeadline(
                      expectedDate: commande.datePrevue,
                      stage: commande.stage,
                    );
                    return FutureBuilder(
                      future: controller.fetchCommandeData(commande),
                      builder: (context, result) {
                        if (result.connectionState == ConnectionState.waiting) {
                          return Shimmer.fromColors(
                            baseColor: AppColors.grey300,
                            highlightColor: AppColors.grey100,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: AppRadius.radiusMd,
                              ),
                            ),
                          );
                        }
                        if (result.hasError) {
                          return const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                            ),
                          );
                        }
                        final tailleur = result.data![0] as UserModel;
                        return GestureDetector(
                          onLongPress: () => _showDeleteOverlay(context),
                          onTap: () => Get.to(
                            () => DetailCommandeView(commande),
                            transition: Transition.downToUp,
                          ),
                          child: CommandeContainer(
                            imageUrl: commande.modeleImage,
                            nomPrenom:
                                controller.userController.isTailleur.value
                                    ? commande.nomClient
                                    : tailleur.nomPrenom!,
                            dateCommande: commande.dateAjout,
                            datePrevue: commande.datePrevue,
                            etat: commande.etatLibelle,
                            deadline: deadline,
                            showAcceptAction:
                                controller.userController.isTailleur.value &&
                                    !commande.isAccepted,
                            onAccept: () => controller.acceptCommande(commande),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class _PrioritySummary extends StatelessWidget {
  const _PrioritySummary({
    required this.overdueCount,
    required this.awaitingCount,
  });

  final int overdueCount;
  final int awaitingCount;

  @override
  Widget build(BuildContext context) {
    if (overdueCount == 0 && awaitingCount == 0) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final messages = <String>[
      if (awaitingCount > 0)
        '$awaitingCount demande${awaitingCount > 1 ? 's' : ''} à accepter',
      if (overdueCount > 0)
        '$overdueCount commande${overdueCount > 1 ? 's' : ''} en retard',
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        0,
      ),
      padding: AppSpacing.paddingAllSm,
      decoration: BoxDecoration(
        color: overdueCount > 0
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.secondaryContainer,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        children: [
          Icon(
            overdueCount > 0
                ? Icons.warning_amber_rounded
                : Icons.inbox_outlined,
            color: overdueCount > 0
                ? theme.colorScheme.onErrorContainer
                : theme.colorScheme.onSecondaryContainer,
          ),
          AppSpacing.gapH8,
          Expanded(
            child: Text(
              messages.join(' · '),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
