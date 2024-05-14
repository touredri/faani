import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:faani/app/modules/message/controllers/discussion_controller.dart';
import 'package:faani/app/modules/message/controllers/message_controller.dart';
import 'package:faani/app/modules/message/views/widgets/chat_list.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spacer/flutter_spacer.dart';

import 'package:get/get.dart';

class DiscussionView extends GetView<DiscussionController> {
  const DiscussionView({super.key});

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Photo Library'),
                      onTap: () {
                        controller.pickImageFromGallery();
                        Get.back();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () {
                      controller.pickImageFromCamera();
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

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
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                              height: 60,
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                controller: controller.textEditingController,
                                decoration: InputDecoration(
                                  hintText: 'Ecrivez un message...',
                                  hintStyle: const TextStyle(fontSize: 13.5),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  suffixIcon: IconButton(
                                    onPressed: () async {
                                      controller.sendMessage();
                                    },
                                    icon: Icon(
                                      Icons.send,
                                      size: 30,
                                      color: controller.textEditingController
                                              .text.isEmpty
                                          ? const Color.fromARGB(
                                              255, 104, 104, 104)
                                          : primaryColor,
                                    ),
                                  ),
                                ),
                              )),
                        ),
                        // record voice
                        IconButton(
                          onPressed: () {
                            controller.recordVoice();
                          },
                          icon: const Icon(
                            Icons.mic,
                            size: 30,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showPicker(context);
                          },
                          icon: const Icon(
                            Icons.add_a_photo,
                            size: 30,
                            color: Color.fromARGB(255, 104, 104, 104),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
