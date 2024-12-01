import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/message_field/message_field.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:faani/app/modules/message/controllers/discussion_controller.dart';
import 'package:faani/app/modules/message/controllers/message_controller.dart';
import 'package:faani/app/modules/message/views/widgets/chat_list.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DiscussionView extends GetView<DiscussionController> {
  const DiscussionView({super.key});


  @override
  Widget build(BuildContext context) {
    Get.put(DiscussionController());
    Get.put(MessageController());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            child: CachedNetworkImage(
              width: double.infinity,
              imageUrl: controller.to_avatar.value,
              fit: BoxFit.cover,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 20,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => shimmer(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.to_name.value),
              const Text(
                'En ligne',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ]),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                size: 30,
              ),
              color: Colors.grey),
        ],
      ),
      body: SafeArea(
        child: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Stack(
              children: [
                const ChatList(),
                Positioned(
                  bottom: 0,
                  height: 60,
                  child: MessageField<DiscussionController>(
                      controller.doc_id.value),
                ),
              ],
            )),
      ),
    );
  }
}
