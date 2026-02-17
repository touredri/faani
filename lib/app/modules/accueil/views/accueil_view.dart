import 'package:faani/app/modules/search_page/views/search_page_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globale_widgets/list_categorie.dart';
import '../controllers/accueil_controller.dart';
import '../widgets/accueil_page_view.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({super.key});

  static const _bgColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    Get.put(AccueilController());

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: _bgColor,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen vertical feed ──────────────────────────
          const Positioned.fill(
            child: AccueilPAgeView(),
          ),

          // ── Top overlay: category filter + search ──────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _bgColor.withValues(alpha: 0.7),
                    _bgColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: CategorieFiltre<AccueilController>(
                        controller: controller,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.to(
                      () => const SearchPageView(),
                      transition: Transition.downToUp,
                    ),
                    icon: const Icon(Icons.search_rounded),
                    color: AppColors.white,
                    iconSize: 24,
                    tooltip: 'Rechercher',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
