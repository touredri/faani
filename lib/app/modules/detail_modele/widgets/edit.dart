import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/modules/globale_widgets/floating_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future<void> editModal(BuildContext context, Modele modele) async {
  await showFloatingModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Modifier les informations'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final updated = await _editModel(context, modele);
              if (updated && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modèle mis à jour.')),
                );
                Navigator.of(context).maybePop();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Supprimer le modèle',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final confirmed = await _confirmDelete(context);
              if (!confirmed) return;
              await ModeleService().delete(modele.id!);
              if (context.mounted) Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    ),
  );
}

Future<bool> _editModel(BuildContext context, Modele modele) async {
  final detailController = TextEditingController(text: modele.detail ?? '');
  var selectedCategory = modele.idCategorie ?? '';
  var selectedGender = modele.genreHabit;
  var isPublic = modele.isPublic == true;

  final result = await showModalBottomSheet<_TailorModelEdit>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: FutureBuilder<List<Categorie>>(
            future: CategorieService().getCategorie().first,
            builder: (context, snapshot) {
              final categories = snapshot.data ?? const <Categorie>[];
              final categoryExists =
                  categories.any((category) => category.id == selectedCategory);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Modifier le modèle',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: detailController,
                      onChanged: (_) => setState(() {}),
                      maxLines: 3,
                      maxLength: 160,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: categoryExists ? selectedCategory : null,
                      hint: const Text('Choisir une catégorie'),
                      items: categories
                          .map((category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.libelle),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        selectedCategory = value ?? selectedCategory;
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                          selectedGender.isEmpty ? null : selectedGender,
                      items: const [
                        DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                        DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                      ],
                      onChanged: (value) => setState(() {
                        selectedGender = value ?? selectedGender;
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Client cible',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Visible dans la découverte'),
                      subtitle: const Text(
                          'Un modèle masqué reste accessible depuis votre portfolio.'),
                      value: isPublic,
                      onChanged: (value) => setState(() => isPublic = value),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: !categoryExists ||
                                selectedGender.isEmpty ||
                                detailController.text.trim().isEmpty
                            ? null
                            : () => Navigator.of(context).pop(
                                  _TailorModelEdit(
                                    detail: detailController.text,
                                    categoryId: selectedCategory,
                                    gender: selectedGender,
                                    isPublic: isPublic,
                                  ),
                                ),
                        child: const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
  detailController.dispose();
  if (result == null || modele.id == null) return false;

  await ModeleService().updateTailorModelDetails(
    modeleId: modele.id!,
    detail: result.detail,
    genreHabit: result.gender,
    categoryId: result.categoryId,
    isPublic: result.isPublic,
  );
  return true;
}

Future<bool> _confirmDelete(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Supprimer le modèle'),
          content: const Text('Voulez-vous vraiment supprimer ce modèle ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ) ??
      false;
}

class _TailorModelEdit {
  const _TailorModelEdit({
    required this.detail,
    required this.categoryId,
    required this.gender,
    required this.isPublic,
  });

  final String detail;
  final String categoryId;
  final String gender;
  final bool isPublic;
}
