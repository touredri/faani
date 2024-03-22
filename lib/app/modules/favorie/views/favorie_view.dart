import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/favorie_controller.dart';

class FavorieView extends GetView<FavorieController> {
  const FavorieView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FavorieView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'FavorieView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
