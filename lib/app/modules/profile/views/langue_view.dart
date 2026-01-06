import 'package:flutter/material.dart';

import 'package:get/get.dart';

class LangueView extends GetView {
  const LangueView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LangueView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'LangueView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
