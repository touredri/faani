import 'package:flutter/material.dart';

import 'package:get/get.dart';

class AideView extends GetView {
  const AideView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AideView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AideView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
