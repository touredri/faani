import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/message/controllers/discussion_controller.dart';
import 'package:faani/app/modules/message/views/widgets/left_msg.dart';
import 'package:faani/app/modules/message/views/widgets/right_msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatList extends GetView<DiscussionController> {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.msgcontentlist.isEmpty) {
        return const Center(
          child: Text(
            'Démarrez la conversation 👋',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        controller: controller.msgScrolling,
        padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
        itemCount: controller.msgcontentlist.length,
        itemBuilder: (context, index) {
          final item = controller.msgcontentlist[index];
          return item.id == user!.uid
              ? chatRightItem(item, context)
              : chatLeftItem(item, context);
        },
      );
    });
  }
}
