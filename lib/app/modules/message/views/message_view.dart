import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/animated_seach.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/message_controller.dart';

class MessageView extends GetView<MessageController> {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MessageController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Discussions'),
        actions: [
          GetBuilder<MessageController>(
            init: MessageController(),
            initState: (_) {},
            id: 'search',
            builder: (_) {
              return AnimatedSearchBar(
                textEditingController: controller.textEditingController,
                isSearching: controller.isSearching,
                onSearch: controller.toggleSearch,
                controller: controller,
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
          if (controller.isSearching.value) {
            controller.toggleSearch();
            controller.textEditingController.clear();
            FocusScope.of(context).unfocus();
          }
        },
        child: StreamBuilder<List<MessageModel>>(
          stream: controller.getMessages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingStateWidget();
            } else if (snapshot.hasError) {
              return ErrorStateWidget(
                message: 'Erreur: ${snapshot.error}',
              );
            } else if (snapshot.data!.isEmpty) {
              return const EmptyStateWidget(
                iconData: Icons.chat_bubble_outline_rounded,
                title: 'Aucune discussion',
                description: 'Vos conversations apparaîtront ici',
              );
            } else {
              return ListView.separated(
                padding: AppSpacing.paddingVSm,
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 80,
                ),
                itemBuilder: (context, index) {
                  final message = snapshot.data![index];
                  final isIncoming = user!.uid == message.to_id!;
                  final contactName =
                      isIncoming ? message.from_name! : message.to_name!;

                  return ListTile(
                    contentPadding: AppSpacing.paddingHLg,
                    leading: CircleAvatar(
                      radius: 28,
                      child: ClipOval(
                        child: imageCacheNetwork(
                          context,
                          message.modele_img!,
                        ),
                      ),
                    ),
                    title: Text(
                      contactName,
                      style: AppTypography.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      message.last_msg!,
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm', 'fr_FR')
                              .format(message.last_time!.toDate()),
                          style: AppTypography.labelSmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.gapV4,
                        Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    onTap: () async {
                      final contactId =
                          isIncoming ? message.from_id! : message.to_id!;
                      final toUser = await UserService().getUser(contactId);
                      controller.goChat(toUser);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
