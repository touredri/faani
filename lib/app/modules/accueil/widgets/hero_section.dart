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
import '../../../style/app_colors.dart';

/// Immersive fullscreen hero section for the home page.
///
/// Shows a premium highlight model with editorial typography and CTAs.
class HeroSection extends StatefulWidget {
  final Modele modele;
  const HeroSection({super.key, required this.modele});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      height: size.height * 0.85,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fullscreen image ──────────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.modele.fichier.isNotEmpty
                  ? widget.modele.fichier[0]!
                  : '',
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

          // ── Bottom gradient ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                    const Color(0xFF1A1A1A).withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // ── Content overlay ──────────────────────────────────
          Positioned(
            bottom: AppSpacing.huge,
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Genre / fabric type
                  Text(
                    widget.modele.genreHabit.toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: const Color(0xFFE0D5C8),
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Title / detail
                  if (widget.modele.detail != null &&
                      widget.modele.detail!.isNotEmpty)
                    Text(
                      widget.modele.detail!,
                      style: AppTypography.displayMedium.copyWith(
                        color: const Color(0xFFF5F0EB),
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppSpacing.xxl),

                  // CTAs
                  Row(
                    children: [
                      // "Voir le modèle"
                      _HeroCta(
                        label: 'Voir le modèle',
                        filled: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Get.to(
                            () => DetailModeleView(widget.modele),
                            transition: Transition.rightToLeft,
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // "Trouver un tailleur"
                      _HeroCta(
                        label: 'Trouver un tailleur',
                        filled: false,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final userController = Get.find<UserController>();
                          if (userController.isTailleur.value) {
                            Get.to(
                              () => DetailModeleView(widget.modele),
                              transition: Transition.rightToLeft,
                            );
                          } else {
                            showTailleurModalBottomSheet(
                                context, widget.modele);
                          }
                        },
                      ),
                    ],
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
