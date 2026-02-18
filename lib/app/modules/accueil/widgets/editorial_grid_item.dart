import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/style/editorial_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../globale_widgets/favorite_icon.dart';

/// A single masonry‑grid card.
/// Shows image, title overlay, fabric type, location, and a save icon.
class EditorialGridItem extends StatefulWidget {
  final Modele modele;
  final double height;
  final VoidCallback onTap;

  const EditorialGridItem({
    super.key,
    required this.modele,
    required this.height,
    required this.onTap,
  });

  @override
  State<EditorialGridItem> createState() => _EditorialGridItemState();
}

class _EditorialGridItemState extends State<EditorialGridItem> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EditorialTheme.cardRadius),
            boxShadow: EditorialTheme.subtleShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(EditorialTheme.cardRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Image ────────────────────────────────────────────────
                if (widget.modele.fichier.isNotEmpty &&
                    widget.modele.fichier[0] != null)
                  CachedNetworkImage(
                    imageUrl: widget.modele.fichier[0]!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: EditorialTheme.surfaceDark,
                      highlightColor: EditorialTheme.surfaceMuted,
                      child: Container(color: EditorialTheme.surfaceDark),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: EditorialTheme.surfaceDark,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: EditorialTheme.offWhite50, size: 24),
                    ),
                  ),

                // ── Bottom gradient overlay ──────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: widget.height * 0.40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Text info ────────────────────────────────────────────
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 36,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.modele.detail ?? '',
                        style: EditorialTheme.gridTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.modele.genreHabit,
                        style: EditorialTheme.gridSubtitle,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                // ── Save / favourite icon ────────────────────────────────
                Positioned(
                  bottom: 8,
                  right: 6,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: FavoriteIcone(
                      docId: widget.modele.id!,
                      color: 'white',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
