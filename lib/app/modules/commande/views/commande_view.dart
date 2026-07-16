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
    final CommandeController commandeController =
        Get.isRegistered<CommandeController>()
            ? Get.find<CommandeController>()
            : Get.put(CommandeController());
    final theme = Theme.of(context);
    final isTailleur = controller.isTailleur.value;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () {
          if (commandeController.isSearching.value) {
            commandeController.toggleSearch();
            commandeController.textEditingController.clear();
            FocusScope.of(context).unfocus();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => commandeController.isSearching.value
                          ? const SizedBox.shrink()
                          : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'A Coudre',
                                    style:
                                        AppTypography.headlineMedium.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    isTailleur
                                        ? 'Gérez vos commandes reçues et enregistrées'
                                        : 'Suivez vos commandes et trouvez des tailleurs',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GetBuilder<CommandeController>(
                      id: 'search',
                      builder: (_) {
                        return AnimatedSearchBar(
                          textEditingController:
                              commandeController.textEditingController,
                          isSearching: commandeController.isSearching,
                          onSearch: commandeController.toggleSearch,
                          controller: commandeController,
                          color: theme.colorScheme.primary,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.paddingHLg,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.radiusXl,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: AppRadius.radiusLg,
                      ),
                      labelColor: AppColors.white,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      labelStyle: AppTypography.labelMedium,
                      unselectedLabelStyle: AppTypography.labelSmall,
                      dividerColor: Colors.transparent,
                      tabs: [
                        _CommandeTab(
                          icon: isTailleur ? Icons.call_received : Icons.send,
                          label: isTailleur ? 'Reçu' : 'Envoyé',
                        ),
                        _CommandeTab(
                          icon: isTailleur
                              ? Icons.save_alt
                              : Icons.people_alt_outlined,
                          label: isTailleur ? 'Enregistré' : 'Tailleurs',
                        ),
                        const _CommandeTab(
                          icon: Icons.done_all,
                          label: 'Terminé',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
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
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_msg',
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 1.5,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMd,
            ),
            onPressed: () => Get.to(
              () => const MessageView(),
              transition: Transition.downToUp,
            ),
            child: const Icon(Icons.sms_outlined),
          ),
          if (isTailleur) ...[
            AppSpacing.gapV12,
            FloatingActionButton(
              heroTag: 'fab_add',
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: AppColors.white,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 2),
            Text(label),
          ],
        ),
      ),
    );
  }
}
