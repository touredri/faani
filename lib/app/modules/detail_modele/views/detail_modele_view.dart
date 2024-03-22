import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/detail_modele_controller.dart';

class DetailModeleView extends GetView<DetailModeleController> {
  const DetailModeleView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailModeleView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailModeleView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
