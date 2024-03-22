import 'package:faani/pages/home/widget/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/accueil_controller.dart';

class AccueilPAgeView extends GetView<AccueilController> {
  @override
  Widget build(BuildContext context) {
    final AccueilController accueilController = Get.put(AccueilController());
    return PageView.builder(
      controller: controller.pageController,
      scrollDirection: Axis.vertical,
      itemCount: accueilController.modeles.length,
      itemBuilder: (context, index) {
        if (accueilController.modeles.isNotEmpty &&
            index < accueilController.modeles.length) {
          final modele = accueilController.modeles[index];
          if (index == accueilController.modeles.length - 1) {
            accueilController.getRandomModele(10, '', '');
          }
          return homeItem(modele, context);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
