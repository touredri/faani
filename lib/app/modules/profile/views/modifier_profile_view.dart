import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ModifierProfileView extends GetView {
  const ModifierProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModifierProfileView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ModifierProfileView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
