import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:faani/app/modules/mesures/views/ajouter_mesure.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/mesure_service.dart';
import '../../../firebase/global_function.dart';
import '../controllers/mesures_controller.dart';
import 'detail_mesure.dart';

class MesuresView extends GetView<MesuresController> {
  const MesuresView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Mesures')),
      body: StreamBuilder<List<Mesure>>(
        stream: MesureService().getAllUserMesure(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorStateWidget(
              message: 'Oups ! Une erreur est survenue',
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingStateWidget();
          }
          if (snapshot.data!.isEmpty) {
            return EmptyStateWidget(
              iconData: Icons.straighten_outlined,
              title: 'Aucune mesure disponible',
              description: 'Ajoutez vos mesures pour les retrouver ici',
              actionLabel: 'Ajouter une mesure',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AjoutMesure()),
              ),
            );
          }
          final data = snapshot.data!;
          return ListView.separated(
            padding: AppSpacing.paddingVSm,
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final mesure = data[index];
              return ListTile(
                onTap: () => Get.to(
                  () => DetailMesure(id: mesure.id!),
                  transition: Transition.rightToLeft,
                ),
                title: Text(
                  mesure.nom!,
                  style: AppTypography.titleSmall.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  DateFormat('d MMMM yyyy', 'fr_FR').format(mesure.date!),
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AjoutMesure()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
