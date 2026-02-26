import 'package:faani/app/data/models/tailor_client.dart';
import 'package:faani/app/data/models/tailor_client_measure.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/data/services/tailor_client_measure_service.dart';
import 'package:faani/app/data/services/tailor_client_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/widgets/choose_modele.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

void _showSnack(
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

class TailorClientsView extends StatefulWidget {
  const TailorClientsView({super.key});

  @override
  State<TailorClientsView> createState() => _TailorClientsViewState();
}

class _TailorClientsViewState extends State<TailorClientsView> {
  final TailorClientService _clientService = TailorClientService();
  final TextEditingController _searchController = TextEditingController();
  bool _withGarmentImageOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    final theme = Theme.of(context);
    final searchText = _searchController.text.trim();
    final hasSearchFilter = searchText.isNotEmpty;
    final hasActiveFilters = hasSearchFilter || _withGarmentImageOnly;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Clients')),
        body: const Center(child: Text('Veuillez vous reconnecter')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Clients'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(hasActiveFilters ? 142 : 92),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher un client',
                    isDense: true,
                  ),
                ),
                Row(
                  children: [
                    Switch(
                      value: _withGarmentImageOnly,
                      onChanged: (value) {
                        setState(() {
                          _withGarmentImageOnly = value;
                        });
                      },
                    ),
                    const Text('Uniquement avec image habit'),
                  ],
                ),
                if (hasActiveFilters) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            if (hasSearchFilter)
                              InputChip(
                                avatar: const Icon(
                                  Icons.filter_alt_outlined,
                                  size: 16,
                                ),
                                label: Text('Recherche: $searchText'),
                                onDeleted: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              ),
                            if (_withGarmentImageOnly)
                              InputChip(
                                avatar: const Icon(
                                  Icons.filter_alt_outlined,
                                  size: 16,
                                ),
                                label: const Text('Avec image habit'),
                                onDeleted: () {
                                  setState(() {
                                    _withGarmentImageOnly = false;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Effacer les filtres actifs',
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _withGarmentImageOnly = false;
                            });
                          },
                          icon: const Icon(Icons.filter_alt_off_outlined),
                          label: const Text('Effacer les filtres actifs'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<TailorClient>>(
        stream: _clientService.getClientsByTailor(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = snapshot.data ?? <TailorClient>[];
          final query = _searchController.text.trim().toLowerCase();
          final filteredClients = clients.where((client) {
            final matchesQuery = query.isEmpty ||
                client.name.toLowerCase().contains(query) ||
                client.phoneNumber.toLowerCase().contains(query) ||
                client.notes.toLowerCase().contains(query);
            final matchesGarmentFilter = !_withGarmentImageOnly ||
                client.garmentImageUrl.trim().isNotEmpty;
            return matchesQuery && matchesGarmentFilter;
          }).toList();

          if (filteredClients.isEmpty) {
            return Center(
              child: Text(
                clients.isEmpty
                    ? 'Aucun client enregistré'
                    : 'Aucun client ne correspond au filtre',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: AppSpacing.pagePadding,
            itemCount: filteredClients.length,
            separatorBuilder: (_, __) => AppSpacing.gapV8,
            itemBuilder: (context, index) {
              final client = filteredClients[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TailorClientDetailView(client: client),
                    ),
                  );
                },
                borderRadius: AppRadius.radiusLg,
                child: Container(
                  padding: AppSpacing.paddingAllMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildClientImage(client),
                      AppSpacing.gapH12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: AppTypography.titleSmall.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            AppSpacing.gapV4,
                            Text(
                              client.phoneNumber.isEmpty
                                  ? 'Téléphone non renseigné'
                                  : client.phoneNumber,
                              style: AppTypography.bodySmall.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (client.notes.trim().isNotEmpty) ...[
                              AppSpacing.gapV4,
                              Text(
                                client.notes,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openEditClientSheet(client),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _deleteClient(client),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateClientSheet,
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
    );
  }

  Widget _buildClientImage(TailorClient client) {
    if (client.garmentImageUrl.trim().isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusMd,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: const Icon(Icons.checkroom_outlined),
      );
    }

    return ClipRRect(
      borderRadius: AppRadius.radiusMd,
      child: Image.network(
        client.garmentImageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _openCreateClientSheet() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    XFile? selectedImage;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nouveau client',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.gapV12,
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  AppSpacing.gapV8,
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                  ),
                  AppSpacing.gapV8,
                  TextField(
                    controller: notesController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  AppSpacing.gapV12,
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked == null) return;
                          setSheetState(() {
                            selectedImage = picked;
                          });
                        },
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Image habit'),
                      ),
                      AppSpacing.gapH8,
                      if (selectedImage != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  AppSpacing.gapV16,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final uid = user?.uid;
                        if (uid == null) return;
                        final clientName = nameController.text.trim();
                        if (clientName.isEmpty) {
                          _showSnack('Nom requis');
                          return;
                        }

                        final now = DateTime.now();
                        final baseClient = TailorClient(
                          id: '',
                          tailorId: uid,
                          name: clientName,
                          phoneNumber: phoneController.text.trim(),
                          notes: notesController.text.trim(),
                          createdAt: now,
                          updatedAt: now,
                        );
                        final newId =
                            await _clientService.createClient(baseClient);

                        if (selectedImage != null) {
                          final upload =
                              await _clientService.uploadGarmentImage(
                            image: selectedImage!,
                            tailorId: uid,
                            clientId: newId,
                          );
                          await _clientService.updateClient(
                            baseClient.copyWith(
                              id: newId,
                              garmentImageUrl: upload['downloadUrl'],
                              garmentImagePath: upload['path'],
                              updatedAt: DateTime.now(),
                            ),
                          );
                        }

                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                        _showSnack(
                          'Client ajouté avec succès',
                          backgroundColor: Colors.green,
                        );
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteClient(TailorClient client) async {
    await _clientService.deleteClient(client);
    _showSnack(
      'Client supprimé',
      backgroundColor: Colors.orange,
    );
  }

  Future<void> _openEditClientSheet(TailorClient client) async {
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(text: client.phoneNumber);
    final notesController = TextEditingController(text: client.notes);
    XFile? selectedImage;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modifier client',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.gapV12,
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  AppSpacing.gapV8,
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                  ),
                  AppSpacing.gapV8,
                  TextField(
                    controller: notesController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  AppSpacing.gapV12,
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked == null) return;
                          setSheetState(() {
                            selectedImage = picked;
                          });
                        },
                        icon: const Icon(Icons.sync_outlined),
                        label: const Text('Remplacer image'),
                      ),
                      AppSpacing.gapH8,
                      if (selectedImage != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  AppSpacing.gapV16,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final updatedName = nameController.text.trim();
                        if (updatedName.isEmpty) {
                          _showSnack('Nom requis');
                          return;
                        }

                        TailorClient updatedClient = client.copyWith(
                          name: updatedName,
                          phoneNumber: phoneController.text.trim(),
                          notes: notesController.text.trim(),
                          updatedAt: DateTime.now(),
                        );

                        if (selectedImage != null) {
                          final upload =
                              await _clientService.replaceGarmentImage(
                            client: client,
                            image: selectedImage!,
                          );
                          updatedClient = updatedClient.copyWith(
                            garmentImageUrl: upload['downloadUrl'],
                            garmentImagePath: upload['path'],
                          );
                        }

                        await _clientService.updateClient(updatedClient);
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                        _showSnack(
                          'Client mis à jour',
                          backgroundColor: Colors.green,
                        );
                      },
                      child: const Text('Mettre à jour'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
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
            tooltip: 'Partager fiche client',
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
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _measureService.deleteMeasure(measure.id),
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
                                label: const Text('Créer commande'),
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
                  _showSnack('Nom de mesure requis');
                  return;
                }

                int parseController(TextEditingController ctrl) {
                  return int.tryParse(ctrl.text.trim()) ?? 0;
                }

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
                _showSnack(
                  'Mesure mise à jour',
                  backgroundColor: Colors.green,
                );
              },
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startOrderFromMeasure(TailorClientMeasure measure) async {
    final currentUser = user;
    if (currentUser == null) {
      _showSnack('Veuillez vous reconnecter');
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

    Get.to(() => const ChooseModeleView(), transition: Transition.rightToLeft);
  }

  Future<void> _duplicateMeasure(TailorClientMeasure measure) async {
    final now = DateTime.now();
    final duplicated = measure.copyWith(
      id: '',
      label: '${measure.label} (copie)',
      createdAt: now,
      updatedAt: now,
    );
    await _measureService.createMeasure(duplicated);
    _showSnack(
      'Mesure dupliquée',
      backgroundColor: Colors.green,
    );
  }

  Future<void> _shareClientSheet() async {
    final currentUser = user;
    if (currentUser == null) return;

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
                  _showSnack('Nom de mesure requis');
                  return;
                }

                int parseController(TextEditingController ctrl) {
                  return int.tryParse(ctrl.text.trim()) ?? 0;
                }

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
                _showSnack(
                  'Mesure enregistrée',
                  backgroundColor: Colors.green,
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Widget _measureInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}
