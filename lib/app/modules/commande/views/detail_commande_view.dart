import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/widgets/build_time_line.dart';
import 'package:faani/app/modules/commande/widgets/image_pop_up.dart';
import 'package:faani/app/modules/commande/widgets/stepper.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/message/controllers/message_controller.dart';
import 'package:faani/app/modules/mesures/views/detail_mesure.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class DetailCommandeView extends GetView<CommandeController> {
  final Commande commande;
  const DetailCommandeView(this.commande, {super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommandeController>()) {
      Get.put(CommandeController());
    }
    if (!Get.isRegistered<MessageController>()) {
      Get.put(MessageController());
    }
    final commandeController = Get.find<CommandeController>();
    final messageController = Get.find<MessageController>();
    const String imageUrl = 'https://robohash.org/98';
    final UserController userController = Get.find();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Détail commande'),
        elevation: 0,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: commandeController.fetchCommandeData(commande),
        builder: (context, result) {
          if (result.connectionState == ConnectionState.waiting) {
            return const LoadingStateWidget(
              message: 'Chargement des informations...',
            );
          }

          if (result.hasError) {
            return ErrorStateWidget(message: 'Erreur: ${result.error}');
          }

          final data = result.data;
          if (data == null || data.length < 3) {
            return const ErrorStateWidget(
                message: 'Données commande indisponibles');
          }

          final tailleur = data[0] as UserModel;
          final client = data[1] as UserModel?;
          final modele = data[2] as Modele;
          final isTailleur = commandeController.userController.isTailleur.value;
          final displayName = isTailleur
              ? commande.nomClient
              : (tailleur.nomPrenom ?? 'Tailleur');
          final displaySubtitle = isTailleur
              ? commande.numeroClient.toString()
              : 'Couture ${tailleur.clientCible ?? '-'}';
          final avatar = isTailleur
              ? (client?.profileImage ?? imageUrl)
              : (tailleur.profileImage ?? imageUrl);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.massive,
            ),
            children: [
              _HeroModeleCard(
                modele: modele,
                onPreview: () {
                  imagePopUp(
                    context: context,
                    imageUrl: modele.fichier[0] ?? '',
                    onButtonPressed: Get.back,
                    size: MediaQuery.sizeOf(context).height * 0.8,
                    buttonText: '',
                    isHaveAction: false,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.45)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    child: imageCacheNetwork(context, avatar),
                  ),
                  title: Text(
                    displayName,
                    style: AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    displaySubtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: GetBuilder<CommandeController>(
                    id: 'commande',
                    builder: (_) {
                      final accepted = commande.isAccepted;
                      return TextButton.icon(
                        onPressed: !isTailleur || accepted
                            ? null
                            : () => commandeController.acceptCommande(commande),
                        icon: Icon(
                          accepted
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_outline_rounded,
                          color:
                              accepted ? AppColors.success : AppColors.grey500,
                        ),
                        label: Text(
                          accepted
                              ? 'Acceptée'
                              : (isTailleur ? 'Accepter' : 'En attente'),
                          style: AppTypography.labelMedium.copyWith(
                            color: accepted
                                ? AppColors.success
                                : AppColors.grey600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  top: AppSpacing.sm,
                  bottom: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.45)),
                ),
                child: Stack(
                  children: [
                    MyStep(commande: commande),
                    Padding(
                      padding: const EdgeInsets.only(top: 65),
                      child: Column(
                        children: [
                          TimelineTile(
                            alignment: TimelineAlign.manual,
                            lineXY: 0.4,
                            isFirst: true,
                            indicatorStyle: const IndicatorStyle(
                              width: 60,
                              height: 60,
                              indicator: IconIndicator(iconData: Icons.info),
                            ),
                            beforeLineStyle: LineStyle(
                              color: AppColors.border.withValues(alpha: 0.7),
                            ),
                            startChild: const SizedBox(height: 80, width: 80),
                            endChild: Padding(
                              padding:
                                  const EdgeInsets.only(left: AppSpacing.md),
                              child: Text(
                                'Autres détails',
                                style: AppTypography.labelMedium.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          buildTimelineTile(
                            title: 'Photo de l\'habit',
                            indicator:
                                const IconIndicator(iconData: Icons.photo),
                            child: GestureDetector(
                              onTap: () {
                                imagePopUp(
                                  context: context,
                                  imageUrl: commande.photoHabit.isNotEmpty
                                      ? commande.photoHabit
                                      : imageUrl,
                                  onButtonPressed: Get.back,
                                  size:
                                      MediaQuery.of(context).size.height * 0.45,
                                  buttonText: 'Change Image 🔄',
                                  isHaveAction: true,
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm),
                                height: 82,
                                child: ClipRRect(
                                  borderRadius: AppRadius.radiusMd,
                                  child: Image.network(
                                    commande.photoHabit,
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: 96,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          buildTimelineTile(
                            title: 'Date prévue',
                            indicator:
                                const IconIndicator(iconData: Icons.date_range),
                            child: SizedBox(
                              height: 88,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat('EEEE d MMMM y', 'fr_FR')
                                          .format(commande.datePrevue),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        commandeController.changeDate(
                                      commande,
                                      context: context,
                                    ),
                                    icon: const Icon(
                                        Icons.edit_calendar_outlined),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buildTimelineTile(
                            title: 'Mesure',
                            indicator:
                                const IconIndicator(iconData: Icons.straighten),
                            isLast: true,
                            child: SizedBox(
                              height: 40,
                              child: Row(
                                children: [
                                  Text(
                                    'Voir les mesures',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  IconButton(
                                    onPressed: () => Get.to(
                                      () => DetailMesure(id: commande.idMesure),
                                    ),
                                    icon: const Icon(Icons.open_in_new),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.45)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  leading: IconButton(
                    onPressed: () => commandeController.changePrice(
                      commande,
                      context: context,
                    ),
                    icon: Icon(
                      commande.prix != 0 && !userController.isTailleur.value
                          ? Icons.monetization_on
                          : Icons.edit,
                      color: AppColors.grey600,
                    ),
                  ),
                  title: Text(
                    'Prix: ${commande.prix} FCFA',
                    style: AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Avance: 0 FCFA',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: TextButton.icon(
                    onPressed: () {
                      if (commande.isSelfAdded) {
                        Get.snackbar(
                          'Erreur',
                          'Vous ne pouvez pas discuter avec vous même',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      messageController.goChat(
                        tailleur,
                        modeleImg: (modele.fichier.isNotEmpty
                                ? modele.fichier[0]
                                : '') ??
                            '',
                        commandeId: commande.id,
                        commandeTitle: modele.detail ?? '',
                      );
                    },
                    icon: const Icon(
                      Icons.message_outlined,
                      color: AppColors.grey600,
                    ),
                    label: Text(
                      'Discuter',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroModeleCard extends StatelessWidget {
  const _HeroModeleCard({required this.modele, required this.onPreview});

  final Modele modele;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusXl,
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.26,
            width: double.infinity,
            child: DisplayImage(modele: modele),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Modèle sélectionné',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                  label: const Text('Voir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
