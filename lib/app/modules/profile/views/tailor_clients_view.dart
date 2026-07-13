import 'package:faani/app/data/models/tailor_client.dart';
import 'package:faani/app/data/services/tailor_client_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/profile/views/tailor_client_detail_view.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
                    const Text('Uniquement avec image d\'habit'),
                  ],
                ),
                if (hasActiveFilters) ...[
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
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
                          label: const Text('Avec image d\'habit'),
                          onDeleted: () {
                            setState(() {
                              _withGarmentImageOnly = false;
                            });
                          },
                        ),
                      Tooltip(
                        message: 'Effacer les filtres actifs',
                        child: ActionChip(
                          avatar: const Icon(
                            Icons.filter_alt_off_outlined,
                            size: 16,
                          ),
                          label: const Text('Effacer'),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _withGarmentImageOnly = false;
                            });
                          },
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

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur lors du chargement des clients',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
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
                        tooltip: 'Modifier client',
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _deleteClient(client),
                        tooltip: 'Supprimer client',
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            width: 56,
            height: 56,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusMd,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: const Icon(Icons.broken_image_outlined),
          );
        },
      ),
    );
  }

  Future<void> _openCreateClientSheet() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    XFile? selectedImage;
    bool isSaving = false;

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
                        label: const Text('Image d\'habit'),
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
                      onPressed: isSaving
                          ? null
                          : () async {
                              setSheetState(() {
                                isSaving = true;
                              });
                              try {
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
                                final newId = await _clientService
                                    .createClient(baseClient);

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

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                                _showSnack(
                                  'Client ajouté avec succès',
                                  backgroundColor: Colors.green,
                                );
                              } catch (_) {
                                _showSnack(
                                    'Erreur lors de la création du client');
                              } finally {
                                if (context.mounted) {
                                  setSheetState(() {
                                    isSaving = false;
                                  });
                                }
                              }
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

    nameController.dispose();
    phoneController.dispose();
    notesController.dispose();
  }

  Future<void> _deleteClient(TailorClient client) async {
    final shouldDelete = await _confirmDeleteClient(client);
    if (!shouldDelete) return;

    try {
      await _clientService.deleteClient(client);
      _showSnack(
        'Client supprimé',
        backgroundColor: Colors.orange,
      );
    } catch (_) {
      _showSnack('Impossible de supprimer ce client pour le moment');
    }
  }

  Future<void> _openEditClientSheet(TailorClient client) async {
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(text: client.phoneNumber);
    final notesController = TextEditingController(text: client.notes);
    XFile? selectedImage;
    bool isSaving = false;

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
                      onPressed: isSaving
                          ? null
                          : () async {
                              setSheetState(() {
                                isSaving = true;
                              });
                              try {
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

                                await _clientService
                                    .updateClient(updatedClient);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                                _showSnack(
                                  'Client mis à jour',
                                  backgroundColor: Colors.green,
                                );
                              } catch (_) {
                                _showSnack(
                                    'Erreur lors de la mise à jour du client');
                              } finally {
                                if (mounted) {
                                  setSheetState(() {
                                    isSaving = false;
                                  });
                                }
                              }
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

    nameController.dispose();
    phoneController.dispose();
    notesController.dispose();
  }

  Future<bool> _confirmDeleteClient(TailorClient client) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce client ?'),
          content: Text(
            'Cette action supprimera ${client.name} et ne pourra pas être annulée.',
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
