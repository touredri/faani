import 'package:faani/app/data/models/user_notification.dart';
import 'package:faani/app/data/services/user_notification_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/commande_service.dart';
import 'package:faani/app/modules/commande/views/detail_commande_view.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/message/controllers/message_controller.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationCenterView extends StatelessWidget {
  const NotificationCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Session expirée.')));
    }
    final service = UserNotificationService();
    return Scaffold(
      appBar: AppBar(title: const Text('Activité')),
      body: StreamBuilder<List<UserNotification>>(
        stream: service.watchForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? const <UserNotification>[];
          if (notifications.isEmpty) {
            return const Center(child: Text('Aucune activité pour le moment.'));
          }
          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => service.markAllAsRead(userId, notifications),
                  child: const Text('Tout marquer comme lu'),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: AppSpacing.pagePadding,
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(_iconFor(notification.category)),
                      ),
                      title: Text(
                        notification.title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.w400
                              : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(notification.body),
                      trailing: notification.isRead
                          ? null
                          : const Icon(Icons.circle, size: 10),
                      onTap: () => _openNotification(
                        context,
                        service,
                        userId,
                        notification,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _iconFor(String category) => switch (category) {
        'message' => Icons.chat_bubble_outline,
        'order' => Icons.receipt_long_outlined,
        'modelModeration' => Icons.verified_outlined,
        _ => Icons.notifications_outlined,
      };

  Future<void> _openNotification(
    BuildContext context,
    UserNotificationService service,
    String userId,
    UserNotification notification,
  ) async {
    if (!notification.isRead) {
      await service.markAsRead(userId, notification.id);
    }
    if (notification.targetType == 'modele' &&
        notification.targetId.isNotEmpty) {
      try {
        final modele =
            await ModeleService().getModeleById(notification.targetId);
        if (context.mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailModeleView(modele)),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ce modèle n’est plus disponible.')),
          );
        }
      }
      return;
    }
    if (notification.targetType == 'commande' &&
        notification.targetId.isNotEmpty) {
      try {
        final commande =
            await CommandeService().getCommande(notification.targetId);
        if (context.mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailCommandeView(commande)),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cette commande n’est plus disponible.'),
            ),
          );
        }
      }
      return;
    }
    if (notification.targetType == 'discussion' &&
        notification.targetId.isNotEmpty) {
      try {
        final controller = Get.isRegistered<MessageController>()
            ? Get.find<MessageController>()
            : Get.put(MessageController());
        final opened = await controller.openThread(notification.targetId);
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cette discussion n’est plus disponible.'),
            ),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d’ouvrir cette discussion.'),
            ),
          );
        }
      }
    }
  }
}
