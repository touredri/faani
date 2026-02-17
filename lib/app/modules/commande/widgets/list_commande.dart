import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/views/detail_commande_view.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/services/commande_service.dart';
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
    final CommandeController controller = Get.put(CommandeController());

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
          final List<Commande> commande = snapshot.data as List<Commande>;
          return GridView.builder(
            padding: AppSpacing.paddingAllMd,
            itemCount: commande.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: MediaQuery.sizeOf(context).width /
                  (MediaQuery.sizeOf(context).height / 1.7),
            ),
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: controller.fetchCommandeData(commande[index]),
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
                  } else if (result.hasError) {
                    return const Center(
                      child: Icon(Icons.error_outline, color: AppColors.error),
                    );
                  } else {
                    final tailleur = result.data![0] as UserModel;
                    return GestureDetector(
                      onLongPress: () => _showDeleteOverlay(context),
                      onTap: () => Get.to(
                        () => DetailCommandeView(commande[index]),
                        transition: Transition.downToUp,
                      ),
                      child: CommandeContainer(
                        imageUrl: commande[index].modeleImage,
                        nomPrenom: controller.userController.isTailleur.value
                            ? commande[index].nomClient
                            : tailleur.nomPrenom!,
                        dateCommande: commande[index].dateAjout,
                        etat: commande[index].etatLibelle,
                      ),
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}
