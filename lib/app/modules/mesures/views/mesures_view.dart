import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/mesures_controller.dart';

class MesuresView extends GetView<MesuresController> {
  const MesuresView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MesuresView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MesuresView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
