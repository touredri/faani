import 'package:flutter/material.dart';

import 'package:get/get.dart';

class CompleteCommandeView extends GetView {
  const CompleteCommandeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CompleteCommandeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CompleteCommandeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
