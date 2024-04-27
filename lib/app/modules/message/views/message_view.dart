// import 'package:faani/app/modules/globale_widgets/animated_seach.dart';
import 'package:faani/app/modules/message/views/discussion_view.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/message_controller.dart';

class MessageView extends GetView<MessageController> {
  const MessageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(MessageController());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldBack,
        title: const Text('Discussions'),
        actions: [
          // AnimatedSearchBar(
          //   textEditingController: controller.textEditingController,
          //   isSearching: controller.isSearching,
          //   onSearch: controller.onSearch,
          //   controller: controller,
          //   color: Colors.white,
          // ),
          GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.search,
              size: 30,
              // color: primaryColor,
            ),
          ),
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
      body: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              leading: const CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage('assets/images/ic_launcher.png'),
              ),
              title: Text('Discussion $index'),
              subtitle: const Text(
                'Votre message ici ...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              trailing: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 20,
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.grey,
                        ),
                        Text('12:00'),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.green,
                    child: Text(
                      '2',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
              onTap: () {
                Get.to(
                  () => const DiscussionView(),
                  transition: Transition.rightToLeftWithFade,
                );
              },
              minVerticalPadding: 15,
            );
          },
          itemCount: 10),
    );
  }
}
