import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/tailor_client.dart';
import 'package:faani/app/data/services/commande_service.dart';
import 'package:faani/app/data/services/tailor_client_service.dart';
import 'package:faani/app/domain/order/order_stage.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/commande/views/commande_view.dart';
import 'package:faani/app/modules/commande/widgets/choose_modele.dart';
import 'package:faani/app/modules/profile/views/mes_modeles_view.dart';
import 'package:faani/app/modules/profile/views/tailor_clients_view.dart';
import 'package:faani/app/modules/profile/views/notification_center_view.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonAtelierView extends StatelessWidget {
  const MonAtelierView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = user;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Veuillez vous reconnecter.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon atelier')),
      body: StreamBuilder<List<Commande>>(
        stream: CommandeService().getAllCommande(),
        builder: (context, ordersSnapshot) {
          final orders = ordersSnapshot.data ?? <Commande>[];
          final activeCount = orders
              .where((order) =>
                  order.stage != OrderStage.completed && !order.isSelfAdded)
              .length;
          final waitingCount =
              orders.where((order) => !order.isAccepted).length;
          final completedCount = orders
              .where((order) => order.stage == OrderStage.completed)
              .length;

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              Text('Aujourd\'hui', style: AppTypography.headlineSmall),
              AppSpacing.gapV4,
              Text(
                'Gardez le rythme de l\'atelier et priorisez les commandes à traiter.',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapV16,
              _OrderSummary(
                active: activeCount,
                waiting: waitingCount,
                completed: completedCount,
              ),
              AppSpacing.gapV24,
              Text('Actions rapides', style: AppTypography.titleMedium),
              AppSpacing.gapV8,
              _ActionRow(
                icon: Icons.add_task_outlined,
                title: 'Enregistrer une commande',
                subtitle: 'Créer une commande pour un client de l\'atelier',
                onTap: () => Get.to(() => const ChooseModeleView()),
              ),
              _ActionRow(
                icon: Icons.receipt_long_outlined,
                title: 'Voir les commandes',
                subtitle: 'Accepter, chiffrer et suivre les délais',
                onTap: () => Get.to(() => const CommandeView()),
              ),
              _ActionRow(
                icon: Icons.notifications_active_outlined,
                title: 'Voir l’activité',
                subtitle: 'Demandes, messages et décisions récentes',
                onTap: () => Get.to(() => const NotificationCenterView()),
              ),
              _ActionRow(
                icon: Icons.people_alt_outlined,
                title: 'Gérer les clients',
                subtitle: 'Retrouver les coordonnées, notes et habits',
                onTap: () => Get.to(() => const TailorClientsView()),
              ),
              _ActionRow(
                icon: Icons.checkroom_outlined,
                title: 'Gérer les modèles',
                subtitle: 'Mettre à jour le catalogue de l\'atelier',
                onTap: () => Get.to(() => const MesModelesView()),
              ),
              AppSpacing.gapV24,
              StreamBuilder<List<TailorClient>>(
                stream:
                    TailorClientService().getClientsByTailor(currentUser.uid),
                builder: (context, clientsSnapshot) {
                  final clientCount = clientsSnapshot.data?.length ?? 0;
                  return Text(
                    '$clientCount client${clientCount > 1 ? 's' : ''} enregistré${clientCount > 1 ? 's' : ''}',
                    style: AppTypography.labelLarge.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.active,
    required this.waiting,
    required this.completed,
  });

  final int active;
  final int waiting;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingAllLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        children: [
          _Metric(value: active, label: 'En cours'),
          _Metric(value: waiting, label: 'À répondre'),
          _Metric(value: completed, label: 'Terminées'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: AppTypography.headlineSmall),
          AppSpacing.gapV4,
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
