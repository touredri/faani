import 'package:faani/app/modules/search_page/views/search_page_view.dart';
import 'package:faani/app/style/editorial_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globale_widgets/list_categorie.dart';
import '../../globale_widgets/circular_progress.dart';
import '../controllers/accueil_controller.dart';
import '../widgets/hero_section.dart';
import '../widgets/editorial_masonry_grid.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccueilController());
    return Scaffold(
      backgroundColor: EditorialTheme.charcoal,
      body: FutureBuilder(
        future: controller.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: circularProgress());
          }
          return Obx(() {
            if (controller.isLoading.value) {
              return Center(child: circularProgress());
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Sticky header: gender toggle + categories + search ──
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  toolbarHeight: 48,
                  backgroundColor:
                      EditorialTheme.charcoal.withOpacity(0.92),
                  automaticallyImplyLeading: false,
                  flexibleSpace: _buildHeader(context),
                ),

                // ── Hero section ────────────────────────────────────────
                if (controller.heroModele.value != null)
                  SliverToBoxAdapter(
                    child: HeroSection(
                        modele: controller.heroModele.value!),
                  ),

                // ── Section title ───────────────────────────────────────
                if (controller.gridModeles.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Explorer',
                        style: EditorialTheme.sectionTitle,
                      ),
                    ),
                  ),

                // ── Masonry grid ────────────────────────────────────────
                EditorialMasonryGrid(
                    modeles: controller.gridModeles),

                // ── Bottom spacer ───────────────────────────────────────
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          });
        },
      ),
    );
  }

  /// Builds the compact sticky header with gender toggle,
  /// horizontal category chips, and search icon.
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(top: 0),
      child: Obx(() => Row(
            children: [
              // Gender toggle
              GestureDetector(
                onTap: () => controller.genreChange(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    controller.isHommeSelected.value ? 'Homme' : 'Femme',
                    style: EditorialTheme.categoryLabelSelected,
                  ),
                ),
              ),
              // Category chips
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: CategorieFiltre<AccueilController>(
                    controller: controller,
                  ),
                ),
              ),
              // Search
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Get.to(() => const SearchPageView(),
                      transition: Transition.downToUp);
                },
                icon: const Icon(
                  Icons.search,
                  color: EditorialTheme.offWhite,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
            ],
          )),
    );
  }
}
