import 'package:faani/app/data/models/favorite_collection_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/accueil/widgets/masonry_grid_item.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../controllers/favorie_controller.dart';

class FavorieView extends StatelessWidget {
  const FavorieView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<FavorieController>()
        ? Get.find<FavorieController>()
        : Get.put(FavorieController());
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Obx(() => Column(
              children: [
                _Header(
                  controller: controller,
                  theme: theme,
                  onCreate: () => _showCollectionDialog(context, controller),
                ),
                _CollectionSelector(
                  controller: controller,
                  onCreate: () => _showCollectionDialog(context, controller),
                  onManage: (collection) =>
                      _showCollectionMenu(context, controller, collection),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(child: _FavoriteGrid(controller: controller)),
              ],
            )),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.theme,
    required this.onCreate,
  });

  final FavorieController controller;
  final ThemeData theme;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: AppRadius.radiusMd,
            ),
            child:
                Icon(Icons.bookmark_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('favorites_title'.tr,
                    style: AppTypography.headlineSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    )),
                Text('favorites_subtitle'.tr,
                    style: AppTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          IconButton(
            onPressed: onCreate,
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'favorites_create_collection'.tr,
          ),
        ],
      ),
    );
  }
}

class _CollectionSelector extends StatelessWidget {
  const _CollectionSelector({
    required this.controller,
    required this.onCreate,
    required this.onManage,
  });

  final FavorieController controller;
  final VoidCallback onCreate;
  final ValueChanged<FavoriteCollection> onManage;

  @override
  Widget build(BuildContext context) {
    final collections = controller.collections;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHLg,
        itemCount: collections.length + 2,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CollectionChip(
              label:
                  '${'favorites_all'.tr} (${controller.countForCollection('')})',
              selected: !controller.hasSelection,
              onPressed: () => controller.selectCollection(''),
            );
          }
          if (index == collections.length + 1) {
            return IconButton.filledTonal(
              onPressed: onCreate,
              tooltip: 'favorites_create_collection'.tr,
              icon: const Icon(Icons.add_rounded),
            );
          }
          final collection = collections[index - 1];
          return _CollectionChip(
            label:
                '${collection.name} (${controller.countForCollection(collection.id)})',
            selected: controller.selectedCollectionId.value == collection.id,
            onPressed: () => controller.selectCollection(collection.id),
            onLongPress: () => onManage(collection),
          );
        },
      ),
    );
  }
}

class _CollectionChip extends StatelessWidget {
  const _CollectionChip({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.onLongPress,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: ChoiceChip(
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        selected: selected,
        onSelected: (_) => onPressed(),
      ),
    );
  }
}

class _FavoriteGrid extends StatelessWidget {
  const _FavoriteGrid({required this.controller});
  final FavorieController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage.value.isNotEmpty) {
      return _FavoritesError(controller: controller);
    }
    if (controller.modeles.isEmpty) {
      return EmptyStateWidget(
        iconData: Icons.bookmark_border_rounded,
        title: controller.hasSelection
            ? 'favorites_collection_empty_title'.tr
            : 'favorites_empty_title'.tr,
        description: controller.hasSelection
            ? 'favorites_collection_empty_body'.tr
            : 'favorites_empty_body'.tr,
      );
    }
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.massive,
      ),
      itemCount: controller.modeles.length,
      itemBuilder: (context, index) {
        final modele = controller.modeles[index];
        return MasonryGridItem(
          modele: modele,
          onTap: () => Get.to(() => DetailModeleView(modele)),
          onLongPress: () => _showModelCollections(context, controller, modele),
        );
      },
    );
  }
}

class _FavoritesError extends StatelessWidget {
  const _FavoritesError({required this.controller});
  final FavorieController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: AppColors.grey500),
            const SizedBox(height: AppSpacing.md),
            Text('favorites_error'.tr, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => Get.reload<FavorieController>(),
              child: Text('favorites_retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showCollectionDialog(
  BuildContext context,
  FavorieController controller, {
  FavoriteCollection? collection,
}) async {
  final textController = TextEditingController(text: collection?.name ?? '');
  final formKey = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(collection == null
          ? 'favorites_new_collection'.tr
          : 'favorites_rename_collection'.tr),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: textController,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: 'favorites_collection_hint'.tr),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'favorites_collection_required'.tr
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text('favorites_cancel'.tr),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            if (collection == null) {
              await controller.createCollection(textController.text);
            } else {
              await controller.renameCollection(
                  collection.id, textController.text);
            }
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          child: Text('favorites_save'.tr),
        ),
      ],
    ),
  );
  textController.dispose();
}

Future<void> _showCollectionMenu(
  BuildContext context,
  FavorieController controller,
  FavoriteCollection collection,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text('favorites_rename_collection'.tr),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _showCollectionDialog(context, controller,
                  collection: collection);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('favorites_delete_collection'.tr,
                style: const TextStyle(color: AppColors.error)),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await controller.deleteCollection(collection.id);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _showModelCollections(
  BuildContext context,
  FavorieController controller,
  Modele modele,
) async {
  final modeleId = modele.id;
  if (modeleId == null || modeleId.isEmpty) return;
  var selected = controller.collectionIdsForModel(modeleId);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('favorites_add_to_collections'.tr,
                    style: AppTypography.titleMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text(modele.detail ?? modele.genreHabit),
              ),
              if (controller.collections.isEmpty)
                Padding(
                  padding: AppSpacing.paddingAllLg,
                  child: Text('favorites_no_collection_yet'.tr),
                )
              else
                ...controller.collections.map((collection) => CheckboxListTile(
                      value: selected.contains(collection.id),
                      title: Text(collection.name),
                      onChanged: (checked) {
                        setSheetState(() {
                          if (checked == true) {
                            selected = {...selected, collection.id};
                          } else {
                            selected = {...selected}..remove(collection.id);
                          }
                        });
                      },
                    )),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: AppSpacing.paddingHLg,
                  child: FilledButton(
                    onPressed: () async {
                      await controller.setModelCollections(modeleId, selected);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    child: Text('favorites_save'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
