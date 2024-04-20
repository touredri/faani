import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AjoutCommandePage extends GetView<CommandeController> {
  const AjoutCommandePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Ajout Commande Page')),
        body: SafeArea(child: Text('AjoutCommandeController')));
  }
}
