import 'package:faani/app/modules/search_page/views/search_page_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globale_widgets/list_categorie.dart';
import '../controllers/accueil_controller.dart';
import '../widgets/accueil_page_view.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccueilController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.backgroundDark,
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
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark.withValues(alpha: 0.85),
                    AppColors.backgroundDark.withValues(alpha: 0.4),
                    AppColors.backgroundDark.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: CategorieFiltre<AccueilController>(
                        controller: controller,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      onPressed: () => Get.to(
                        () => const SearchPageView(),
                        transition: Transition.downToUp,
                      ),
                      icon: const Icon(Icons.search_rounded),
                      color: AppColors.white,
                      iconSize: 22,
                      tooltip: 'Rechercher',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom swipe hint ──────────────────────────────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: _SwipeHint(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated swipe indicator hint
class _SwipeHint extends StatefulWidget {
  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Icon(
            Icons.keyboard_arrow_up_rounded,
            color: AppColors.white.withValues(alpha: 0.35),
            size: 28,
          ),
        );
      },
    );
  }
}
