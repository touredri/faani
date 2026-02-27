import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/data/models/tailor_client.dart';
import 'package:faani/app/data/models/tailor_client_measure.dart';
import 'package:faani/app/data/services/tailor_client_measure_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/widgets/choose_modele.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

void _showClientDetailSnack(
  String message, {
  Color backgroundColor = Colors.red,
}) {
  final context = Get.overlayContext ?? Get.context;
  if (context == null) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ),
  );
}

class TailorClientDetailView extends StatefulWidget {
  final TailorClient client;

  const TailorClientDetailView({super.key, required this.client});

  @override
  State<TailorClientDetailView> createState() => _TailorClientDetailViewState();
}

class _TailorClientDetailViewState extends State<TailorClientDetailView> {
  final TailorClientMeasureService _measureService =
      TailorClientMeasureService();
  final List<String> _garmentTypes = const [
    'Boubou',
    'Robe',
    'Chemise',
    'Pantalon',
    'Costume',
    'Personnalisé',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = user;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.client.name)),
        body: const Center(child: Text('Veuillez vous reconnecter')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        actions: [
          IconButton(
            onPressed: _shareClientSheet,
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Partager la fiche client',
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          Container(
            padding: AppSpacing.paddingAllMd,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.client.phoneNumber.isEmpty
                      ? 'Téléphone non renseigné'
                      : widget.client.phoneNumber,
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (widget.client.notes.trim().isNotEmpty) ...[
                  AppSpacing.gapV8,
                  Text(
                    widget.client.notes,
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.gapV12,
          Text(
            'Mesures du client',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapV8,
          StreamBuilder<List<TailorClientMeasure>>(
            stream: _measureService.getMeasuresByClient(
              tailorId: currentUser.uid,
              clientId: widget.client.id,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Container(
                  padding: AppSpacing.paddingAllMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    'Erreur lors du chargement des mesures',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              }

              final measures = snapshot.data ?? <TailorClientMeasure>[];
              if (measures.isEmpty) {
                return Container(
                  padding: AppSpacing.paddingAllMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    'Aucune mesure enregistrée',
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return Column(
                children: measures
                    .map(
                      (measure) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: AppSpacing.paddingAllMd,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: AppRadius.radiusLg,
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    measure.label,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _duplicateMeasure(measure),
                                  icon: const Icon(Icons.copy_outlined),
                                  tooltip: 'Dupliquer',
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _openEditMeasureDialog(measure),
                                  tooltip: 'Modifier',
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  onPressed: () => _deleteMeasure(measure),
                                  tooltip: 'Supprimer',
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            Text(
                              'Épaule ${measure.epaule} • Bras ${measure.bras} • Poignet ${measure.poignet}',
                              style: AppTypography.bodySmall,
                            ),
                            AppSpacing.gapV4,
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  label: Text(measure.garmentType),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            Text(
                              'Poitrine ${measure.poitrine} • Taille ${measure.taille} • Hanche ${measure.hanche}',
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              'Ventre ${measure.ventre} • Longueur ${measure.longueur}',
                              style: AppTypography.bodySmall,
                            ),
                            if (measure.notes.trim().isNotEmpty)
                              Text(
                                measure.notes,
                                style: AppTypography.bodySmall.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            AppSpacing.gapV8,
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _startOrderFromMeasure(measure),
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Créer une commande'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateMeasureDialog,
        child: const Icon(Icons.straighten_outlined),
      ),
    );
  }

  Future<void> _openEditMeasureDialog(TailorClientMeasure measure) async {
    final labelController = TextEditingController(text: measure.label);
    final epauleController =
        TextEditingController(text: measure.epaule.toString());
    final brasController = TextEditingController(text: measure.bras.toString());
    final poignetController =
        TextEditingController(text: measure.poignet.toString());
    final poitrineController =
        TextEditingController(text: measure.poitrine.toString());
    final tailleController =
        TextEditingController(text: measure.taille.toString());
    final hancheController =
        TextEditingController(text: measure.hanche.toString());
    final ventreController =
        TextEditingController(text: measure.ventre.toString());
    final longueurController =
        TextEditingController(text: measure.longueur.toString());
    final notesController = TextEditingController(text: measure.notes);
    String selectedGarmentType = measure.garmentType;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la mesure'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedGarmentType,
                      decoration:
                          const InputDecoration(labelText: 'Type de vêtement'),
                      items: _garmentTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setStateDialog(() {
                          selectedGarmentType = value;
                        });
                      },
                    ),
                    TextField(
                      controller: labelController,
                      decoration:
                          const InputDecoration(labelText: 'Nom mesure'),
                    ),
                    _measureInput(epauleController, 'Épaule'),
                    _measureInput(brasController, 'Bras'),
                    _measureInput(poignetController, 'Poignet'),
                    _measureInput(poitrineController, 'Poitrine'),
                    _measureInput(tailleController, 'Taille'),
                    _measureInput(hancheController, 'Hanche'),
                    _measureInput(ventreController, 'Ventre'),
                    _measureInput(longueurController, 'Longueur'),
                    TextField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final label = labelController.text.trim();
                if (label.isEmpty) {
                  _showClientDetailSnack('Nom de mesure requis');
                  return;
                }

                int parseController(TextEditingController ctrl) {
                  return int.tryParse(ctrl.text.trim()) ?? 0;
                }

                try {
                  final updated = measure.copyWith(
                    label: label,
                    garmentType: selectedGarmentType,
                    epaule: parseController(epauleController),
                    bras: parseController(brasController),
                    poignet: parseController(poignetController),
                    poitrine: parseController(poitrineController),
                    taille: parseController(tailleController),
                    hanche: parseController(hancheController),
                    ventre: parseController(ventreController),
                    longueur: parseController(longueurController),
                    notes: notesController.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  await _measureService.updateMeasure(updated);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                  _showClientDetailSnack(
                    'Mesure mise à jour',
                    backgroundColor: Colors.green,
                  );
                } catch (_) {
                  _showClientDetailSnack(
                    'Erreur lors de la mise à jour de la mesure',
                  );
                }
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    );

    labelController.dispose();
    epauleController.dispose();
    brasController.dispose();
    poignetController.dispose();
    poitrineController.dispose();
    tailleController.dispose();
    hancheController.dispose();
    ventreController.dispose();
    longueurController.dispose();
    notesController.dispose();
  }

  Future<void> _startOrderFromMeasure(TailorClientMeasure measure) async {
    final currentUser = user;
    if (currentUser == null) {
      _showClientDetailSnack('Veuillez vous reconnecter');
      return;
    }

    final legacyMesure = Mesure(
      bras: measure.bras,
      epaule: measure.epaule,
      hanche: measure.hanche,
      idUser: currentUser.uid,
      longueur: measure.longueur,
      poitrine: measure.poitrine,
      nom: '${widget.client.name} - ${measure.garmentType} - ${measure.label}',
      id: '',
      taille: measure.taille,
      ventre: measure.ventre,
      poignet: measure.poignet,
      date: DateTime.now(),
      updateDate: DateTime.now(),
    );

    try {
      await legacyMesure.create();

      final commandeController = Get.isRegistered<CommandeController>()
          ? Get.find<CommandeController>()
          : Get.put(CommandeController());

      final sanitizedPhone =
          widget.client.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      commandeController.clearForm();
      commandeController.mesure.value = legacyMesure;
      commandeController.nomController.text = widget.client.name;
      commandeController.numeroController.text = sanitizedPhone;

      Get.to(() => const ChooseModeleView(),
          transition: Transition.rightToLeft);
    } catch (_) {
      _showClientDetailSnack(
        'Impossible de créer la commande pour le moment',
      );
    }
  }

  Future<void> _duplicateMeasure(TailorClientMeasure measure) async {
    final now = DateTime.now();
    final duplicated = measure.copyWith(
      id: '',
      label: '${measure.label} (copie)',
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _measureService.createMeasure(duplicated);
      _showClientDetailSnack(
        'Mesure dupliquée',
        backgroundColor: Colors.green,
      );
    } catch (_) {
      _showClientDetailSnack('Erreur lors de la duplication de la mesure');
    }
  }

  Future<void> _shareClientSheet() async {
    final currentUser = user;
    if (currentUser == null) return;

    try {
      final measures = await _measureService
          .getMeasuresByClient(
            tailorId: currentUser.uid,
            clientId: widget.client.id,
          )
          .first;

      final buffer = StringBuffer()
        ..writeln('Fiche Client - ${widget.client.name}')
        ..writeln(
            'Téléphone: ${widget.client.phoneNumber.isEmpty ? '-' : widget.client.phoneNumber}')
        ..writeln(
            'Notes: ${widget.client.notes.isEmpty ? '-' : widget.client.notes}')
        ..writeln('')
        ..writeln('Mesures (${measures.length})')
        ..writeln('-----------------------------');

      for (final measure in measures) {
        buffer
          ..writeln('${measure.garmentType} - ${measure.label}')
          ..writeln(
              'Épaule ${measure.epaule}, Bras ${measure.bras}, Poignet ${measure.poignet}')
          ..writeln(
              'Poitrine ${measure.poitrine}, Taille ${measure.taille}, Hanche ${measure.hanche}')
          ..writeln('Ventre ${measure.ventre}, Longueur ${measure.longueur}')
          ..writeln('Notes: ${measure.notes.isEmpty ? '-' : measure.notes}')
          ..writeln('');
      }

      await Share.share(
        buffer.toString(),
        subject: 'Fiche client ${widget.client.name}',
      );
    } catch (_) {
      _showClientDetailSnack('Impossible de partager la fiche client');
    }
  }

  Future<void> _openCreateMeasureDialog() async {
    final labelController = TextEditingController();
    final epauleController = TextEditingController();
    final brasController = TextEditingController();
    final poignetController = TextEditingController();
    final poitrineController = TextEditingController();
    final tailleController = TextEditingController();
    final hancheController = TextEditingController();
    final ventreController = TextEditingController();
    final longueurController = TextEditingController();
    final notesController = TextEditingController();
    String selectedGarmentType = _garmentTypes.first;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une mesure'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedGarmentType,
                      decoration:
                          const InputDecoration(labelText: 'Type de vêtement'),
                      items: _garmentTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setStateDialog(() {
                          selectedGarmentType = value;
                        });
                      },
                    ),
                    TextField(
                      controller: labelController,
                      decoration:
                          const InputDecoration(labelText: 'Nom mesure'),
                    ),
                    _measureInput(epauleController, 'Épaule'),
                    _measureInput(brasController, 'Bras'),
                    _measureInput(poignetController, 'Poignet'),
                    _measureInput(poitrineController, 'Poitrine'),
                    _measureInput(tailleController, 'Taille'),
                    _measureInput(hancheController, 'Hanche'),
                    _measureInput(ventreController, 'Ventre'),
                    _measureInput(longueurController, 'Longueur'),
                    TextField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = user?.uid;
                if (uid == null) return;

                final label = labelController.text.trim();
                if (label.isEmpty) {
                  _showClientDetailSnack('Nom de mesure requis');
                  return;
                }

                int parseController(TextEditingController ctrl) {
                  return int.tryParse(ctrl.text.trim()) ?? 0;
                }

                try {
                  final now = DateTime.now();
                  final measure = TailorClientMeasure(
                    id: '',
                    tailorId: uid,
                    clientId: widget.client.id,
                    label: label,
                    garmentType: selectedGarmentType,
                    epaule: parseController(epauleController),
                    bras: parseController(brasController),
                    poignet: parseController(poignetController),
                    poitrine: parseController(poitrineController),
                    taille: parseController(tailleController),
                    hanche: parseController(hancheController),
                    ventre: parseController(ventreController),
                    longueur: parseController(longueurController),
                    notes: notesController.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  );

                  await _measureService.createMeasure(measure);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                  _showClientDetailSnack(
                    'Mesure enregistrée',
                    backgroundColor: Colors.green,
                  );
                } catch (_) {
                  _showClientDetailSnack(
                    'Erreur lors de l\'enregistrement de la mesure',
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    labelController.dispose();
    epauleController.dispose();
    brasController.dispose();
    poignetController.dispose();
    poitrineController.dispose();
    tailleController.dispose();
    hancheController.dispose();
    ventreController.dispose();
    longueurController.dispose();
    notesController.dispose();
  }

  Widget _measureInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _deleteMeasure(TailorClientMeasure measure) async {
    final shouldDelete = await _confirmDeleteMeasure(measure.label);
    if (!shouldDelete) return;

    try {
      await _measureService.deleteMeasure(measure.id);
      _showClientDetailSnack(
        'Mesure supprimée',
        backgroundColor: Colors.orange,
      );
    } catch (_) {
      _showClientDetailSnack('Impossible de supprimer cette mesure');
    }
  }

  Future<bool> _confirmDeleteMeasure(String label) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer cette mesure ?'),
          content: Text(
            'La mesure "$label" sera supprimée définitivement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
