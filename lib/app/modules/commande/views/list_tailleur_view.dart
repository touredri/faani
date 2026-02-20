import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/modules/commande/views/tailor_profile_page.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListTailleurView extends GetView {
  const ListTailleurView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<UserModel>>(
      stream: UserService().getAllTailleur(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingStateWidget(
              message: 'Chargement des tailleurs...');
        }

        if (snapshot.hasError) {
          return ErrorStateWidget(
            message: 'Une erreur est survenue ${snapshot.error}',
          );
        }

        final users = snapshot.data ?? <UserModel>[];
        if (users.isEmpty) {
          return const EmptyStateWidget(
            iconData: Icons.people_outline,
            title: 'Aucun tailleur disponible',
            description: 'Les tailleurs apparaîtront ici',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.massive,
          ),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final tailleur = users[index];
            return _TailleurCard(tailleur: tailleur, theme: theme);
          },
        );
      },
    );
  }
}

class _TailleurCard extends StatelessWidget {
  const _TailleurCard({required this.tailleur, required this.theme});

  final UserModel tailleur;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.radiusLg,
      onTap: () => Get.to(() => TailorProfilePage(tailor: tailleur)),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: tailleur.profileImage != null &&
                        tailleur.profileImage!.isNotEmpty
                    ? CachedNetworkImageProvider(tailleur.profileImage!)
                    : NetworkImage(getRandomProfileImageUrl()) as ImageProvider,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tailleur.nomPrenom ?? 'Tailleur',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            tailleur.adress ?? 'Adresse non disponible',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '125',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FutureBuilder<int>(
                          future:
                              ModeleService().getTotalModeleCount(tailleur.id!),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            return Text(
                              'Modèles: $count',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.grey700,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
