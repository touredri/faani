import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globale_widgets/circular_progress.dart';
import '../controllers/accueil_controller.dart';
import 'accueil_model_view.dart';

class AccueilPAgeView extends GetView<AccueilController> {
  @override
  Widget build(BuildContext context) {
    final AccueilController accueilController = Get.put(AccueilController());

    return FutureBuilder(
      future: accueilController.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: circularProgress());
        } else {
          return PageView.builder(
            controller: controller.pageController,
            scrollDirection: Axis.vertical,
            itemCount: accueilController.modeles.length,
            itemBuilder: (context, index) {
              if (accueilController.modeles.isNotEmpty &&
                  index < accueilController.modeles.length) {
                final modele = accueilController.modeles[index];
                // if (index == accueilController.modeles.length - 1) {
                //   accueilController.getRandomModele(10, '', '');
                // }
                return HomeItem(modele);
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        }
      },
    );
  }
}
