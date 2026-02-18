import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/accueil/widgets/category_scroll_view.dart';
import 'package:faani/app/modules/accueil/widgets/editorial_grid_item.dart';
import 'package:faani/app/style/editorial_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

/// Masonry grid section showing models in a staggered editorial layout.
/// Each item has a different aspect‑ratio height for visual variety.
class EditorialMasonryGrid extends StatelessWidget {
  final List<Modele> modeles;

  const EditorialMasonryGrid({super.key, required this.modeles});

  @override
  Widget build(BuildContext context) {
    if (modeles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EditorialTheme.gridPadding,
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: EditorialTheme.gridSpacing,
        crossAxisSpacing: EditorialTheme.gridSpacing,
        childCount: modeles.length,
        itemBuilder: (context, index) {
          final modele = modeles[index];
          // Vary heights for editorial feel
          final heightFactor = _heightForIndex(index);
          final height = 180.0 + (heightFactor * 100.0);

          return EditorialGridItem(
            modele: modele,
            height: height,
            onTap: () {
              // Open TikTok-like vertical scroll filtered by same category
              Get.to(
                () => CategoryScrollView(
                  initialModele: modele,
                  idCategorie: modele.idCategorie ?? '',
                ),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 350),
              );
            },
          );
        },
      ),
    );
  }

  /// Deterministic pseudo‑random height factor per index.
  double _heightForIndex(int index) {
    // Pattern: tall, short, medium, tall, medium, short …
    const pattern = [1.2, 0.6, 0.9, 1.0, 0.7, 1.1, 0.8, 1.3];
    return pattern[index % pattern.length];
  }
}
