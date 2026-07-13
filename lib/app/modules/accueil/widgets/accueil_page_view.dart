import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
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
          return _buildShimmerLoading();
        } else {
          return GetBuilder<AccueilController>(builder: (_) {
            return RefreshIndicator(
              onRefresh: controller.refreshPage,
              color: AppColors.primary,
              backgroundColor: AppColors.black,
              child: PageView.builder(
                controller: controller.pageController,
                scrollDirection: Axis.vertical,
                itemCount: controller.modeles.length,
                itemBuilder: (context, index) {
                  if (controller.modeles.isNotEmpty &&
                      index < controller.modeles.length) {
                    final modele = controller.modeles[index];
                    if (index == controller.modeles.length - 1 &&
                        controller.homeController.hasMoreData.value) {
                      controller.loadMore();
                    }
                    return HomeItem(modele, controller: controller);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            );
          });
        }
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        children: [
          Expanded(
            child: Container(color: AppColors.shimmerBase),
          ),
        ],
      ),
    );
  }
}
