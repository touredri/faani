import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/list_tailleur_bottom_sheet.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/style/editorial_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Fullscreen hero section highlighting a premium model.
/// Immersive, editorial — strong typography + subtle CTAs.
class HeroSection extends StatelessWidget {
  final Modele modele;
  const HeroSection({super.key, required this.modele});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height * 0.85,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────────────
          if (modele.fichier.isNotEmpty && modele.fichier[0] != null)
            ClipRRect(
              child: CachedNetworkImage(
                imageUrl: modele.fichier[0]!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: EditorialTheme.surfaceDark,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: EditorialTheme.offWhite50,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: EditorialTheme.surfaceDark,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: EditorialTheme.offWhite50, size: 40),
                ),
              ),
            ),

          // ── Gradient overlay ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.65),
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
          ),

          // ── Content overlay ───────────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title / headline
                Text(
                  modele.detail ?? 'Collection',
                  style: EditorialTheme.heroHeadline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitleText(),
                  style: EditorialTheme.heroBody,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                // CTAs row
                Row(
                  children: [
                    _HeroCta(
                      label: 'Voir le modèle',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => DetailModeleView(modele),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 400));
                      },
                    ),
                    const SizedBox(width: 12),
                    _HeroCta(
                      label: 'Trouver un tailleur',
                      outlined: true,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final userController = Get.find<UserController>();
                        if (userController.isTailleur.value) {
                          Get.to(() => DetailModeleView(modele),
                              transition: Transition.fadeIn);
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
      ),
    );
  }

  String _subtitleText() {
    final genre = modele.genreHabit;
    return genre.isNotEmpty ? 'Mode $genre' : 'Inspiration mode';
  }
}

/// Minimal, elegant CTA button used inside the hero section.
class _HeroCta extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _HeroCta({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  State<_HeroCta> createState() => _HeroCtaState();
}

class _HeroCtaState extends State<_HeroCta> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.outlined
                ? Colors.transparent
                : EditorialTheme.offWhite,
            border: Border.all(
              color: EditorialTheme.offWhite,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: EditorialTheme.heroCta.copyWith(
              color: widget.outlined
                  ? EditorialTheme.offWhite
                  : EditorialTheme.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
