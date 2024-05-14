import 'package:faani/app/data/models/message_modele.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/animated_seach.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/message_controller.dart';

class MessageView extends GetView<MessageController> {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MessageController());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldBack,
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
                  color: Colors.black,
                );
              }),
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.keyboard_arrow_down_outlined,
              size: 45,
              // color: primaryColor,
            ),
          )
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
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemBuilder: (context, index) {
                  final message = snapshot.data![index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 35,
                      child: imageCacheNetwork(context, message.modele_img!),
                    ),
                    title: Text(user!.uid == message.to_id!
                        ? message.from_name!
                        : message.to_name!),
                    subtitle: Text(
                      message.last_msg!,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 52,
                          child: Row(
                            children: [
                              Text(
                                DateFormat('HH:mm', 'fr_FR')
                                    .format(message.last_time!.toDate())
                                    .toString(),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check,
                          size: 19,
                          color: Colors.grey,
                        )
                      ],
                    ),
                    onTap: () async {
                      final to_user = await UserService().getUser(
                          user!.uid == message.to_id!
                              ? message.from_id!
                              : message.to_id!);
                      controller.goChat(to_user);
                    },
                    minVerticalPadding: 15,
                  );
                },
                itemCount: snapshot.data!.length,
              );
            }
          },
        ),
      ),
    );
  }
}
