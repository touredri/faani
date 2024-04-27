import 'package:faani/app/modules/message/controllers/message_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DiscussionView extends GetView {
  const DiscussionView({super.key});
  @override
  Widget build(BuildContext context) {
    final MessageController controller = Get.put(MessageController());
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
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/ic_launcher.png'),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Toure Hamidou'),
              Text(
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
      body: Column(
        children: [
          // Expanded(
          //   // make the whatsapp like chat screen
            
          // ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.textEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Ecrivez votre message ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
