import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ajout_commande_controller.dart';

class AjoutCommandeView extends GetView<AjoutCommandeController> {
  const AjoutCommandeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AjoutCommandeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AjoutCommandeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
