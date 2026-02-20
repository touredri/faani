import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/animated_seach.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/message_controller.dart';

class MessageView extends GetView<MessageController> {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MessageController>()) {
      Get.put(MessageController());
    }
    final messageController = Get.find<MessageController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Icon(
                Icons.chat_bubble_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discussions',
                    style: AppTypography.titleLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Messagerie avec vos clients et tailleurs',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          GetBuilder<MessageController>(
            id: 'search',
            builder: (_) {
              return AnimatedSearchBar(
                textEditingController: messageController.textEditingController,
                isSearching: messageController.isSearching,
                onSearch: messageController.toggleSearch,
                controller: messageController,
                color: theme.colorScheme.onSurface,
              );
            },
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconSize: 32,
            tooltip: 'Fermer',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (messageController.isSearching.value) {
            messageController.toggleSearch();
            messageController.textEditingController.clear();
            FocusScope.of(context).unfocus();
          }
        },
        child: StreamBuilder<List<MessageModel>>(
          stream: messageController.getMessages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingStateWidget(
                  message: 'Chargement des discussions...');
            } else if (snapshot.hasError) {
              return ErrorStateWidget(
                message: 'Erreur: ${snapshot.error}',
              );
            }

            final baseMessages = snapshot.data ?? <MessageModel>[];
            if (baseMessages.isEmpty) {
              return const EmptyStateWidget(
                iconData: Icons.chat_bubble_outline_rounded,
                title: 'Aucune discussion',
                description: 'Vos conversations apparaîtront ici',
              );
            }

            return Obx(() {
              final messages = messageController.filterMessages(baseMessages);
              if (messages.isEmpty) {
                return const EmptyStateWidget(
                  iconData: Icons.search_off_rounded,
                  title: 'Aucun résultat',
                  description: 'Essayez un autre nom ou mot-clé',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.massive,
                ),
                itemCount: messages.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isIncoming = user?.uid == message.to_id;
                  final contactName = isIncoming
                      ? (message.from_name ?? 'Contact')
                      : (message.to_name ?? 'Contact');
                  final preview = (message.last_msg ?? '').trim().isEmpty
                      ? 'Nouvelle discussion'
                      : message.last_msg!.trim();
                  final time = message.last_time != null
                      ? DateFormat('HH:mm', 'fr_FR')
                          .format(message.last_time!.toDate())
                      : '--:--';

                  return InkWell(
                    borderRadius: AppRadius.radiusLg,
                    onTap: () async {
                      final contactId = isIncoming
                          ? message.from_id ?? ''
                          : message.to_id ?? '';
                      if (contactId.isEmpty) return;
                      final toUser = await UserService().getUser(contactId);
                      await messageController.goChat(
                        toUser,
                        modeleImg: message.modele_img ?? '',
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppRadius.radiusLg,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Padding(
                        padding: AppSpacing.paddingAllMd,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.radiusMd,
                              child: SizedBox(
                                width: 54,
                                height: 54,
                                child: imageCacheNetwork(
                                  context,
                                  message.modele_img ?? '',
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contactName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    preview,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  time,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Icon(
                                  Icons.done_all_rounded,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            });
          },
        ),
      ),
    );
  }
}
