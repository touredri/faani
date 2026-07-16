import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/message_field/message_field.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:faani/app/modules/message/controllers/discussion_controller.dart';
import 'package:faani/app/modules/commande/views/detail_commande_view.dart';
import 'package:faani/app/modules/message/views/widgets/chat_list.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DiscussionView extends GetView<DiscussionController> {
  const DiscussionView({super.key});

  Future<void> _showMoreActions(
    BuildContext context,
    DiscussionController controller,
  ) async {
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.topXl),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.copy_all_outlined),
                  title: const Text('Copier ID de la discussion'),
                  onTap: () async {
                    final navigator = Navigator.of(sheetContext);
                    await Clipboard.setData(
                      ClipboardData(text: controller.docId.value),
                    );
                    navigator.pop();
                    Get.snackbar(
                      'Copié',
                      'ID de discussion copié',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('Effacer les messages'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final shouldClear = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Effacer les messages'),
                            content: const Text(
                              'Voulez-vous effacer tous les messages de cette discussion ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Annuler'),
                              ),
                              FilledButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Effacer'),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (!shouldClear) return;
                    await controller.clearConversationMessages();
                    Get.snackbar(
                      'Succès',
                      'Messages effacés',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Supprimer la discussion',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final shouldDelete = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Supprimer la discussion'),
                            content: const Text(
                              'Cette action est définitive. Continuer ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Annuler'),
                              ),
                              FilledButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (!shouldDelete) return;
                    await controller.deleteConversation();
                    if (Get.isOverlaysOpen) {
                      Get.back();
                    }
                    Get.back();
                    Get.snackbar(
                      'Succès',
                      'Discussion supprimée',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DiscussionController>()) {
      Get.put(DiscussionController());
    }
    final discussionController = Get.find<DiscussionController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusFull,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                child: ClipOval(
                  child: CachedNetworkImage(
                    width: 36,
                    height: 36,
                    imageUrl: discussionController.toAvatar.value,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => shimmer(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, size: 18),
                  ),
                ),
              ),
            ),
            AppSpacing.gapH12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    discussionController.toName.value,
                    style: AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (discussionController.commandeTitle.value.isNotEmpty)
                    Text(
                      discussionController.commandeTitle.value,
                      style: AppTypography.labelSmall.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    discussionController.commandeId.value.isEmpty
                        ? 'Discussion'
                        : 'Discussion liée à une commande',
                    style: AppTypography.labelSmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showMoreActions(context, discussionController),
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Plus',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Obx(() {
              final commande = discussionController.commande.value;
              if (discussionController.commandeId.value.isEmpty) {
                return const SizedBox.shrink();
              }
              if (discussionController.isCommandeLoading.value) {
                return const LinearProgressIndicator(minHeight: 2);
              }
              if (commande == null) {
                return const SizedBox.shrink();
              }
              return InkWell(
                onTap: () => Get.to(() => DetailCommandeView(commande)),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  padding: AppSpacing.paddingAllSm,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      AppSpacing.gapH8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              discussionController.commandeTitle.value.isEmpty
                                  ? 'Commande en cours'
                                  : discussionController.commandeTitle.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelLarge,
                            ),
                            Text(
                              commande.etatLibelle,
                              style: AppTypography.labelSmall.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            }),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: ChatList(),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: SizedBox(
                height: 58,
                child: MessageField<DiscussionController>(
                  discussionController.docId.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
