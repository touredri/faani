import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void showTailleurModalBottomSheet(BuildContext context, Modele modele) {
  final TextEditingController searchController = TextEditingController();

  showCupertinoModalBottomSheet(
    expand: false,
    context: context,
    useRootNavigator: true,
    builder: (context) {
      final theme = Theme.of(context);
      return StatefulBuilder(builder: (context, setModalState) {
        final String query = searchController.text.trim().toLowerCase();

        return StreamBuilder<List<UserModel>>(
          stream: UserService().getAllTailleur(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: LoadingStateWidget(),
              );
            }

            if (snapshot.hasError) {
              return const SizedBox(
                height: 300,
                child: EmptyStateWidget(
                  iconData: Icons.error_outline,
                  title: 'Erreur de chargement des tailleurs',
                ),
              );
            }

            final List<UserModel> allTailleurs = snapshot.data ?? <UserModel>[];
            final List<UserModel> filteredTailleurs = query.isEmpty
                ? allTailleurs
                : allTailleurs.where((tailleur) {
                    final String nom = (tailleur.nomPrenom ?? '').toLowerCase();
                    final String cible =
                        (tailleur.clientCible ?? '').toLowerCase();
                    final String adresse =
                        (tailleur.adress ?? '').toLowerCase();
                    return nom.contains(query) ||
                        cible.contains(query) ||
                        adresse.contains(query);
                  }).toList();

            if (allTailleurs.isEmpty) {
              return const SizedBox(
                height: 300,
                child: EmptyStateWidget(
                  iconData: Icons.person_search_outlined,
                  title: 'Aucun tailleur disponible',
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                titleSpacing: AppSpacing.lg,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: AppRadius.radiusFull,
                        ),
                      ),
                    ),
                    AppSpacing.gapV12,
                    Text(
                      'Choisissez un tailleur',
                      style: AppTypography.titleMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    AppSpacing.gapV4,
                    Text(
                      '${filteredTailleurs.length} résultat${filteredTailleurs.length > 1 ? 's' : ''}',
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  AppSpacing.gapH8,
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setModalState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom, cible ou adresse',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  setModalState(() {});
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filteredTailleurs.isEmpty
                        ? const EmptyStateWidget(
                            iconData: Icons.search_off_rounded,
                            title: 'Aucun résultat pour cette recherche',
                          )
                        : ListView.separated(
                            padding: AppSpacing.paddingVSm,
                            itemCount: filteredTailleurs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 2),
                            itemBuilder: (context, index) {
                              final UserModel tailleur =
                                  filteredTailleurs[index];
                              final String nom =
                                  (tailleur.nomPrenom ?? '').trim().isEmpty
                                      ? 'Tailleur'
                                      : tailleur.nomPrenom!.trim();
                              final String cible =
                                  (tailleur.clientCible ?? '').trim().isEmpty
                                      ? 'Tous'
                                      : tailleur.clientCible!.trim();
                              final String adresse =
                                  (tailleur.adress ?? '').trim().isEmpty
                                      ? 'Adresse non renseignée'
                                      : tailleur.adress!.trim();

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    nom.characters.first.toUpperCase(),
                                    style: AppTypography.labelLarge,
                                  ),
                                ),
                                title: Text(
                                  nom,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  'Couture pour $cible • $adresse',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onTap: () {
                                  Get.find<AccueilController>()
                                      .selectedTailleur
                                      .value = tailleur;

                                  Navigator.of(context).maybePop();

                                  if (auth.currentUser!.isAnonymous) {
                                    showCustomSnackbar(
                                      message:
                                          'Vous devez vous connecter pour faire une commande',
                                    );
                                  } else {
                                    Get.to(
                                        () => AjoutCommandePage(
                                              modele,
                                              tailleur: tailleur,
                                            ),
                                        transition: Transition.rightToLeft);
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      });
    },
  );
}
