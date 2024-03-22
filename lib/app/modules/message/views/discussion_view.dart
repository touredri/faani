import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DiscussionView extends GetView {
  const DiscussionView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DiscussionView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DiscussionView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
