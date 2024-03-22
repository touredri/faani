import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ajout_modele_controller.dart';

class AjoutModeleView extends GetView<AjoutModeleController> {
  const AjoutModeleView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AjoutModeleView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AjoutModeleView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
