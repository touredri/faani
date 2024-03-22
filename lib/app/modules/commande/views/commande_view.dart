import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/commande_controller.dart';

class CommandeView extends GetView<CommandeController> {
  const CommandeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CommandeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CommandeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
