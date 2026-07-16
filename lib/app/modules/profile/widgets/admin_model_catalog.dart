import 'dart:io';

import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/profile/controllers/admin_model_catalog_controller.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminModelCatalog extends StatefulWidget {
  const AdminModelCatalog({
    super.key,
    required this.modeleService,
  });

  final ModeleService modeleService;

  @override
  State<AdminModelCatalog> createState() => _AdminModelCatalogState();
}

class _AdminModelCatalogState extends State<AdminModelCatalog> {
  late final AdminModelCatalogController _controller;
  final _searchController = TextEditingController();
  String _status = 'all';
  String _categoryId = 'all';
  String _tailorId = 'all';

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AdminModelCatalogController());
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Categorie>>(
      stream: CategorieService().getCategorie(),
      builder: (context, categoriesSnapshot) {
        final categories = (categoriesSnapshot.data ?? const <Categorie>[])
            .where((category) => category.id != '1' && category.id != '8')
            .toList();
        return StreamBuilder<List<UserModel>>(
          stream: UserService().getAllUsers(),
          builder: (context, usersSnapshot) {
            final tailors = (usersSnapshot.data ?? const <UserModel>[])
                .where((user) => user.isTailleur)
                .toList();
            return StreamBuilder<List<Modele>>(
              stream: widget.modeleService.getAllModeles(),
              builder: (context, modelsSnapshot) {
                if (modelsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final models = _filteredModels(
                    modelsSnapshot.data ?? const [], categories);
                return Column(
                  children: [
                    _buildToolbar(context, categories, tailors, models.length),
                    Expanded(
                        child: _buildModelList(context, models, categories)),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  List<Modele> _filteredModels(
      List<Modele> models, List<Categorie> categories) {
    final query = _searchController.text.trim().toLowerCase();
    final categoryLabels = {
      for (final category in categories)
        category.id: category.libelle.toLowerCase(),
    };
    final filtered = models.where((model) {
      final matchesStatus = _status == 'all' || _statusFor(model) == _status;
      final matchesCategory =
          _categoryId == 'all' || model.idCategorie == _categoryId;
      final matchesTailor = _tailorId == 'all' || model.idTailleur == _tailorId;
      final haystack = [
        model.detail ?? '',
        model.genreHabit,
        model.idTailleur,
        categoryLabels[model.idCategorie] ?? '',
        if (model.isFaaniContent) 'faani',
      ].join(' ').toLowerCase();
      return matchesStatus &&
          matchesCategory &&
          matchesTailor &&
          (query.isEmpty || haystack.contains(query));
    }).toList();
    filtered.sort((a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0)
        .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));
    return filtered;
  }

  Widget _buildToolbar(
    BuildContext context,
    List<Categorie> categories,
    List<UserModel> tailors,
    int count,
  ) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_outlined),
                    hintText: 'Rechercher un modèle',
                  ),
                ),
              ),
              AppSpacing.gapH8,
              IconButton.filled(
                tooltip: 'Ajouter un contenu Faani',
                onPressed: () => _openEditor(categories: categories),
                icon: const Icon(Icons.add_photo_alternate_outlined),
              ),
            ],
          ),
          AppSpacing.gapV8,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterMenu<String>(
                  value: _status,
                  tooltip: 'Filtrer par statut',
                  icon: Icons.tune_outlined,
                  entries: const {
                    'all': 'Tous statuts',
                    'pending': 'En attente',
                    'published': 'Publié',
                    'hidden': 'Dépublié',
                    'rejected': 'Refusé',
                  },
                  onChanged: (value) => setState(() => _status = value),
                ),
                AppSpacing.gapH8,
                _filterMenu<String>(
                  value: _categoryId,
                  tooltip: 'Filtrer par catégorie',
                  icon: Icons.category_outlined,
                  entries: {
                    'all': 'Toutes catégories',
                    for (final c in categories) c.id: c.libelle
                  },
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                AppSpacing.gapH8,
                _filterMenu<String>(
                  value: _tailorId,
                  tooltip: 'Filtrer par tailleur',
                  icon: Icons.storefront_outlined,
                  entries: {
                    'all': 'Tous les tailleurs',
                    for (final t in tailors) t.id!: t.nomPrenom ?? 'Tailleur'
                  },
                  onChanged: (value) => setState(() => _tailorId = value),
                ),
                AppSpacing.gapH12,
                Text('$count résultat${count > 1 ? 's' : ''}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterMenu<T>({
    required T value,
    required String tooltip,
    required IconData icon,
    required Map<T, String> entries,
    required ValueChanged<T> onChanged,
  }) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onChanged,
      itemBuilder: (context) => entries.entries
          .map((entry) =>
              PopupMenuItem(value: entry.key, child: Text(entry.value)))
          .toList(),
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(entries[value] ?? ''),
      ),
    );
  }

  Widget _buildModelList(
      BuildContext context, List<Modele> models, List<Categorie> categories) {
    if (models.isEmpty) {
      return const Center(
          child: Text('Aucun modèle ne correspond aux filtres.'));
    }
    final categoryLabels = {
      for (final category in categories) category.id: category.libelle
    };
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: models.length,
      separatorBuilder: (_, __) => AppSpacing.gapV8,
      itemBuilder: (context, index) => _buildModelTile(
        context,
        models[index],
        categoryLabels[models[index].idCategorie] ?? 'Sans catégorie',
        categories,
      ),
    );
  }

  Widget _buildModelTile(BuildContext context, Modele model, String category,
      List<Categorie> categories) {
    final theme = Theme.of(context);
    final mediaUrl = model.fichier.isNotEmpty ? model.fichier.first : null;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
      child: InkWell(
        borderRadius: AppRadius.radiusMd,
        onTap: () => Get.to(() => DetailModeleView(model)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.radiusSm,
                child: SizedBox(
                  width: 76,
                  height: 96,
                  child: mediaUrl == null || mediaUrl.isEmpty
                      ? ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image_not_supported_outlined),
                        )
                      : Image.network(mediaUrl, fit: BoxFit.cover),
                ),
              ),
              AppSpacing.gapH12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _statusChip(context, model),
                        if (model.isFaaniContent)
                          const Chip(label: Text('Faani')),
                      ],
                    ),
                    AppSpacing.gapV8,
                    Text(
                      model.detail?.trim().isNotEmpty == true
                          ? model.detail!
                          : 'Sans description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall,
                    ),
                    AppSpacing.gapV4,
                    Text('$category · ${model.genreHabit}',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              PopupMenuButton<_CatalogAction>(
                tooltip: 'Actions du modèle',
                onSelected: (action) =>
                    _handleAction(model, action, categories),
                itemBuilder: (context) => _actionsFor(model)
                    .map((action) => PopupMenuItem(
                          value: action,
                          child: Row(children: [
                            Icon(action.icon, size: 18),
                            AppSpacing.gapH8,
                            Text(action.label)
                          ]),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, Modele model) {
    final status = _statusFor(model);
    final colors = switch (status) {
      'published' => (Colors.green, 'Publié'),
      'rejected' => (Theme.of(context).colorScheme.error, 'Refusé'),
      'hidden' => (Colors.orange, 'Dépublié'),
      _ => (Colors.blueGrey, 'En attente'),
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(colors.$2),
      side: BorderSide(color: colors.$1.withValues(alpha: 0.45)),
    );
  }

  String _statusFor(Modele model) {
    if (model.isRejected) return 'rejected';
    if (model.isApproved && model.isPublic == true) return 'published';
    if (model.isApproved) return 'hidden';
    return 'pending';
  }

  List<_CatalogAction> _actionsFor(Modele model) {
    final actions = <_CatalogAction>[_CatalogAction.edit];
    switch (_statusFor(model)) {
      case 'published':
        actions.addAll([_CatalogAction.depublish, _CatalogAction.reject]);
      case 'rejected':
        actions.add(_CatalogAction.restore);
      default:
        actions.addAll([_CatalogAction.publish, _CatalogAction.reject]);
    }
    return actions;
  }

  Future<void> _handleAction(
      Modele model, _CatalogAction action, List<Categorie> categories) async {
    if (action == _CatalogAction.edit) {
      _openEditor(categories: categories, model: model);
      return;
    }
    String? reason;
    if (action == _CatalogAction.reject) {
      reason = await _askReason();
      if (reason == null) return;
    }
    final confirmed = await _confirm(action, model);
    if (!confirmed || !mounted) return;
    try {
      switch (action) {
        case _CatalogAction.publish:
          await _controller.publish(model);
        case _CatalogAction.depublish:
          await _controller.depublish(model);
        case _CatalogAction.reject:
          await _controller.reject(model, reason!);
        case _CatalogAction.restore:
          await _controller.restore(model);
        case _CatalogAction.edit:
          return;
      }
      _showSuccess('Action enregistrée et ajoutée à l’audit.');
    } catch (_) {
      _showError('Impossible d’enregistrer cette action.');
    }
  }

  Future<void> _openEditor(
      {required List<Categorie> categories, Modele? model}) async {
    final result = await showModalBottomSheet<_ModelEditorResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ModelEditorSheet(categories: categories, model: model),
    );
    if (result == null || !mounted) return;
    try {
      if (model == null) {
        await _controller.createFaaniContent(
          detail: result.detail,
          genreHabit: result.genreHabit,
          categoryId: result.categoryId,
          isPublic: result.isPublic,
          images: result.images,
        );
      } else {
        await _controller.updateModel(
          modele: model,
          detail: result.detail,
          genreHabit: result.genreHabit,
          categoryId: result.categoryId,
          isPublic: result.isPublic,
          replacementImages: result.images,
        );
      }
      _showSuccess(
          model == null ? 'Contenu Faani ajouté.' : 'Modèle mis à jour.');
    } catch (error) {
      _showError(error is FormatException
          ? error.message.toString()
          : 'Modification impossible.');
    }
  }

  Future<bool> _confirm(_CatalogAction action, Modele model) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${action.label} ce modèle ?'),
            content:
                Text('Cette action sera inscrite dans le journal d’audit.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(action.label)),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _askReason() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motif du refus'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'Expliquez la décision au tailleur'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _showSuccess(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
  void _showError(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error));
}

enum _CatalogAction {
  edit('Modifier', Icons.edit_outlined),
  publish('Publier', Icons.publish_outlined),
  depublish('Dépublier', Icons.visibility_off_outlined),
  reject('Refuser', Icons.block_outlined),
  restore('Restaurer', Icons.restore_outlined);

  const _CatalogAction(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _ModelEditorResult {
  const _ModelEditorResult({
    required this.detail,
    required this.genreHabit,
    required this.categoryId,
    required this.isPublic,
    required this.images,
  });

  final String detail;
  final String genreHabit;
  final String categoryId;
  final bool isPublic;
  final List<File> images;
}

class _ModelEditorSheet extends StatefulWidget {
  const _ModelEditorSheet({required this.categories, this.model});

  final List<Categorie> categories;
  final Modele? model;

  @override
  State<_ModelEditorSheet> createState() => _ModelEditorSheetState();
}

class _ModelEditorSheetState extends State<_ModelEditorSheet> {
  late final TextEditingController _detailController;
  late String _gender;
  late String _categoryId;
  late bool _isPublic;
  List<File> _images = <File>[];

  @override
  void initState() {
    super.initState();
    final model = widget.model;
    _detailController = TextEditingController(text: model?.detail ?? '');
    _gender = model?.genreHabit ?? 'Homme';
    _categoryId = model?.idCategorie ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : '');
    _isPublic = model?.isPublic ?? true;
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final selected = await ImagePicker().pickMultiImage();
    if (selected.isEmpty || !mounted) {
      return;
    }
    setState(
        () => _images = selected.map((image) => File(image.path)).toList());
  }

  void _submit() {
    final detail = _detailController.text.trim();
    if (detail.isEmpty ||
        _categoryId.isEmpty ||
        (widget.model == null && _images.isEmpty)) {
      return;
    }
    Navigator.pop(
      context,
      _ModelEditorResult(
        detail: detail,
        genreHabit: _gender,
        categoryId: _categoryId,
        isPublic: _isPublic,
        images: _images,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.model == null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isNew ? 'Nouveau contenu Faani' : 'Modifier le modèle',
                  style: AppTypography.titleLarge),
              AppSpacing.gapV16,
              TextField(
                  controller: _detailController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description')),
              AppSpacing.gapV12,
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Genre'),
                items: const [
                  DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                  DropdownMenuItem(value: 'Femme', child: Text('Femme'))
                ],
                onChanged: (value) =>
                    setState(() => _gender = value ?? _gender),
              ),
              AppSpacing.gapV12,
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: widget.categories
                    .map((category) => DropdownMenuItem(
                        value: category.id, child: Text(category.libelle)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _categoryId = value ?? _categoryId),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Visible dans le catalogue public'),
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
              ),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(_images.isEmpty
                    ? (isNew ? 'Ajouter les images' : 'Remplacer les images')
                    : '${_images.length} image(s) sélectionnée(s)'),
              ),
              if (!isNew && _images.isEmpty) ...[
                AppSpacing.gapV4,
                Text('Les images actuelles sont conservées.',
                    style: AppTypography.bodySmall),
              ],
              AppSpacing.gapV20,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(isNew
                      ? 'Créer le contenu Faani'
                      : 'Enregistrer les modifications'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
