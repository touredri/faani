import 'package:faani/app/modules/ajout_modele/controllers/ajout_modele_controller.dart';
import 'package:faani/app/modules/ajout_modele/widgets/modele_form.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/list_categorie.dart';
import 'package:faani/app/modules/globale_widgets/modele_card.dart';
import 'package:faani/app/modules/profile/controllers/tailor_portfolio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../style/app_colors.dart';

class MesModelesView extends GetView<TailorPortfolioController> {
  const MesModelesView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TailorPortfolioController>();
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            backgroundColor: AppColors.primary,
            expandedHeight: 108.0,
            floating: true,
            snap: true,
            pinned: true,
            bottom: PreferredSize(
                preferredSize: const Size(double.infinity, 35),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  color: AppColors.primary,
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  child: CategorieFiltre<TailorPortfolioController>(
                    controller: controller,
                  ),
                )),
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.accessibility_rounded,
                          color: Colors.white,
                        ),
                        Obx(() => Text(
                              controller.total.value.toString(),
                              style: const TextStyle(color: Colors.white),
                            )),
                      ],
                    ),
                    Obx(() => _PortfolioMetric(
                          icon: Icons.visibility_outlined,
                          value: controller.totalViews.value,
                          label: 'Vues',
                        )),
                    Obx(() => _PortfolioMetric(
                          icon: Icons.favorite_border,
                          value: controller.totalLikes.value,
                          label: 'J\'aime',
                        )),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              final pending = controller.pendingModeration.value;
              if (pending == 0) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$pending modèle${pending > 1 ? 's' : ''} en attente de modération',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SliverFillRemaining(
            child: GetBuilder<TailorPortfolioController>(
              id: 'mesModeles',
              builder: (_) {
                return customMansoryGridView(
                  3,
                  controller.mesModelesList.value.length,
                  (context, index) {
                    final modele = controller.mesModelesList.value[index];
                    return Stack(
                      children: [
                        buildCard(modele!, context: context, onTap: () {
                          Get.to(
                              () => DetailModeleView(
                                    modele,
                                    previousIsProfile: true,
                                  ),
                              arguments: modele);
                        }),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _ModerationBadge(modele: modele),
                        ),
                      ],
                    );
                  },
                  scrollController: controller.scrollController,
                  padding: 10,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.put(AjoutModeleController());
          Get.to(() => const AjoutModeleForm());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PortfolioMetric extends StatelessWidget {
  const _PortfolioMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        Text(
          value.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class _ModerationBadge extends StatelessWidget {
  const _ModerationBadge({required this.modele});

  final Modele modele;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (modele) {
      Modele(isRejected: true) => ('Refusé', Colors.red.shade700),
      Modele(isApproved: true, isPublic: true) => (
          'Publié',
          Colors.green.shade700
        ),
      Modele(isApproved: true) => ('Masqué', Colors.blueGrey.shade700),
      _ => ('En revue', Colors.orange.shade800),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
