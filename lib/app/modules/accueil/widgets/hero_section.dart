import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/list_tailleur_bottom_sheet.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import '../../../style/app_colors.dart';

/// Immersive fullscreen hero section for the home page.
///
/// Shows a premium highlight model with editorial typography and CTAs.
class HeroSection extends StatefulWidget {
  final List<Modele> modeles;
  const HeroSection({super.key, required this.modeles});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.modeles.length <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextIndex = (_currentIndex + 1) % widget.modeles.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modeles.length != widget.modeles.length) {
      _currentIndex = 0;
      _startAutoScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.modeles.isEmpty) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.modeles.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final modele = widget.modeles[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl:
                        modele.fichier.isNotEmpty ? modele.fichier[0]! : '',
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 600),
                    fadeInCurve: Curves.easeIn,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.shimmerBase,
                      highlightColor: AppColors.shimmerHighlight,
                      child: Container(color: AppColors.shimmerBase),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.backgroundDark,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppColors.grey600, size: 48),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.55,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                          const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: AppSpacing.huge,
                  left: AppSpacing.xxl,
                  right: AppSpacing.xxl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        modele.genreHabit.toUpperCase(),
                        style: AppTypography.labelMedium.copyWith(
                          color: const Color(0xFFE0D5C8),
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (modele.detail != null && modele.detail!.isNotEmpty)
                        Text(
                          modele.detail!,
                          style: AppTypography.displayMedium.copyWith(
                            color: const Color(0xFFF5F0EB),
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: AppSpacing.xxl),
                      Row(
                        children: [
                          _HeroCta(
                            label: 'Voir le modèle',
                            filled: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Get.to(
                                () => DetailModeleView(modele),
                                transition: Transition.rightToLeft,
                              );
                            },
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _HeroCta(
                            label: 'Trouver un tailleur',
                            filled: false,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              final userController = Get.find<UserController>();
                              if (userController.isTailleur.value) {
                                Get.to(
                                  () => DetailModeleView(modele),
                                  transition: Transition.rightToLeft,
                                );
                              } else {
                                showTailleurModalBottomSheet(context, modele);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        if (widget.modeles.length > 1)
          Positioned(
            bottom: AppSpacing.lg,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.modeles.length, (index) {
                final isActive = _currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.white.withValues(alpha: 0.95)
                        : AppColors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// Minimal CTA button for the hero section.
class _HeroCta extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeroCta({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_HeroCta> createState() => _HeroCtaState();
}

class _HeroCtaState extends State<_HeroCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: widget.filled
                ? const Color(0xFFF5F0EB).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFF5F0EB).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: const Color(0xFFF5F0EB),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
