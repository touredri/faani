import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import '../../globale_widgets/circular_progress.dart';
import '../controllers/accueil_controller.dart';
import 'accueil_model_view.dart';

class AccueilPAgeView extends GetView<AccueilController> {
  const AccueilPAgeView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: circularProgress());
        } else {
          return GetBuilder<AccueilController>(
              init: AccueilController(),
              initState: (_) {},
              builder: (_) {
                return PageView.builder(
                  controller: controller.pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: controller.modeles.length,
                  itemBuilder: (context, index) {
                    if (controller.modeles.isNotEmpty &&
                        index < controller.modeles.length) {
                      final modele = controller.modeles[index];
                      if (index == controller.modeles.length - 1) {
                        controller.loadMore('', '');
                      }
                      return HomeItem(modele);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              });
        }
      },
    );
  }
}
