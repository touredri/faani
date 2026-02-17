import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/views/list_tailleur_view.dart';
import 'package:faani/app/modules/commande/widgets/choose_modele.dart';
import 'package:faani/app/modules/globale_widgets/animated_seach.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/message/views/message_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faani/app/modules/commande/widgets/circle_indicator.dart';
import 'package:faani/app/modules/commande/widgets/list_commande.dart';

class CommandeView extends StatefulWidget {
  const CommandeView({super.key});

  @override
  State<CommandeView> createState() => _CommandeViewState();
}

class _CommandeViewState extends State<CommandeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find();
    final CommandeController commandeController = Get.put(CommandeController());
    final theme = Theme.of(context);
    final isTailleur = controller.isTailleur.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'A Coudre',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          GetBuilder<CommandeController>(
            init: CommandeController(),
            initState: (_) {},
            id: 'search',
            builder: (_) {
              return Padding(
                padding: AppSpacing.paddingAllSm,
                child: AnimatedSearchBar(
                  textEditingController:
                      commandeController.textEditingController,
                  isSearching: commandeController.isSearching,
                  onSearch: commandeController.toggleSearch,
                  controller: commandeController,
                  color: AppColors.white,
                ),
              );
            },
          ),
        ],
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        bottom: TabBar(
          controller: _tabController,
          indicator: CircleTabIndicator(
            color: AppColors.white,
            radius: 3,
          ),
          indicatorPadding: const EdgeInsets.only(bottom: 45),
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
          labelStyle: AppTypography.labelMedium,
          unselectedLabelStyle: AppTypography.labelSmall,
          tabs: [
            _CommandeTab(
              icon: isTailleur ? Icons.call_received : Icons.send,
              label: isTailleur ? 'Reçu' : 'Envoyé',
            ),
            _CommandeTab(
              icon: isTailleur ? Icons.save_alt : Icons.people_alt_outlined,
              label: isTailleur ? 'Enregistré' : 'Tailleurs',
            ),
            const _CommandeTab(
              icon: Icons.done_all,
              label: 'Terminé',
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (commandeController.isSearching.value) {
            commandeController.toggleSearch();
            commandeController.textEditingController.clear();
            FocusScope.of(context).unfocus();
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            const ListCommande(status: 'receive'),
            isTailleur
                ? const ListCommande(status: 'save')
                : const ListTailleurView(),
            const ListCommande(status: 'finish'),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_msg',
            backgroundColor: AppColors.grey600,
            elevation: 1,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMd,
            ),
            onPressed: () => Get.to(
              () => const MessageView(),
              transition: Transition.downToUp,
            ),
            child: const Icon(Icons.sms_outlined, color: AppColors.white),
          ),
          if (isTailleur) ...[
            AppSpacing.gapV12,
            FloatingActionButton(
              heroTag: 'fab_add',
              onPressed: () => Get.to(
                () => const ChooseModeleView(),
                transition: Transition.downToUp,
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ],
      ),
    );
  }
}

/// Extracted tab widget to reduce duplication in TabBar.
class _CommandeTab extends StatelessWidget {
  const _CommandeTab({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}
