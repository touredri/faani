import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/message_field/message_field.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:faani/app/modules/message/controllers/discussion_controller.dart';
import 'package:faani/app/modules/message/controllers/message_controller.dart';
import 'package:faani/app/modules/message/views/widgets/chat_list.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscussionView extends GetView<DiscussionController> {
  const DiscussionView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DiscussionController());
    Get.put(MessageController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              child: ClipOval(
                child: CachedNetworkImage(
                  width: 36,
                  height: 36,
                  imageUrl: controller.to_avatar.value,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => shimmer(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person, size: 18),
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
                    controller.to_name.value,
                    style: AppTypography.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'En ligne',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Plus',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: ChatList()),
            SizedBox(
              height: 60,
              child: MessageField<DiscussionController>(
                controller.doc_id.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
