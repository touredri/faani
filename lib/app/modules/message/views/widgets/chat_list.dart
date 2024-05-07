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
    return Obx(() => Container(
          padding: EdgeInsets.only(bottom: 50.h),
          child: CustomScrollView(
            reverse: true,
            controller: controller.msgScrolling,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = controller.msgcontentlist[index];
                    return item.id == user!.uid
                        ? chatRightItem(item, context)
                        : chatLeftItem(item, context);
                  },
                  childCount: controller.msgcontentlist.length,
                ),
              ),
            ],
          ),
        ));
  }
}
