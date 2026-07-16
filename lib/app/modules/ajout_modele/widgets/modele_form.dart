import 'dart:io';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/modules/ajout_modele/controllers/ajout_modele_controller.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../style/app_colors.dart';

class AjoutModeleForm extends GetView<AjoutModeleController> {
  const AjoutModeleForm({super.key});

  @override
  Widget build(BuildContext context) {
    final AjoutModeleController controller = Get.find();
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: AppColors.primary,
        ),
        body: Obx(
          () => SingleChildScrollView(
            child: Column(
              children: [
                if (controller.hasDraft.value)
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restore_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Brouillon local restauré',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.clearDraft,
                          child: const Text('Effacer'),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.47,
                  child: Stack(
                    children: [
                      PageView(
                        controller: controller.pageController,
                        onPageChanged: (int index) {
                          controller.pageController.jumpToPage(index);
                        },
                        children: [
                          if (controller.images.isNotEmpty)
                            for (var image in controller.images)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                child: Image.file(
                                  File(image.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                          if (controller.images.isEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              child: Image.asset(
                                'assets/images/ic_launcher.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                            height: 50,
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    controller.pickOrTakeImage(context, true);
                                  },
                                  icon: const Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    controller.pickOrTakeImage(context, false);
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                                // delete image
                                IconButton(
                                  onPressed: () {
                                    controller.images.removeAt(controller
                                        .pageController.page!
                                        .toInt());
                                    controller.scheduleDraftSave();
                                    controller.update();
                                    if (controller.images.isEmpty) {
                                      Get.back();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                      ),
                      shadowBackButton(context),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SmoothPageIndicator(
                  controller: controller.pageController,
                  count:
                      controller.images.isEmpty ? 1 : controller.images.length,
                  effect: const ExpandingDotsEffect(
                    dotColor: Colors.grey,
                    activeDotColor: AppColors.primary,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.detailTextController,
                        onChanged: (_) => controller.scheduleDraftSave(),
                        maxLines: 3,
                        maxLength: 160,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Description du modèle',
                          hintText: 'Décrivez la coupe, le tissu ou l’occasion',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // drop down button for category
                      DropdownButtonFormField<String>(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: controller.categorieList.any(
                                (categorie) =>
                                    categorie.id ==
                                    controller.selectedCategoryId.value)
                            ? controller.selectedCategoryId.value
                            : null,
                        hint: const Text('Choisir une catégorie'),
                        items:
                            controller.categorieList.map((Categorie categorie) {
                          return DropdownMenuItem<String>(
                            value: categorie.id,
                            child: Text(categorie.libelle),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value == null) return;
                          controller.selectedCategoryId.value = value;
                          controller.scheduleDraftSave();
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Client cible',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        initialValue: ['Homme', 'Femme']
                                .contains(controller.selectedGender.value)
                            ? controller.selectedGender.value
                            : null,
                        items: <String>['Homme', 'Femme'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedGender.value = newValue;
                            controller.scheduleDraftSave();
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      SwitchListTile(
                        activeThumbColor: AppColors.primary,
                        title: const Text(
                          'Rendre votre modèle public ?',
                          style: TextStyle(fontSize: 15),
                        ),
                        value: controller.isPublic.value,
                        onChanged: (bool value) {
                          controller.isPublic.value = value;
                          controller.scheduleDraftSave();
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 60),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final shouldSubmit = await _showPublishReview(
                              context,
                              controller,
                            );
                            if (!shouldSubmit) return;
                            final success = await controller.createModel();
                            if (success) {
                              Get.defaultDialog(
                                title: controller.isPublic.value
                                    ? 'Publication envoyée'
                                    : 'Contenu masqué enregistré',
                                middleText: controller.isPublic.value
                                    ? 'Votre modèle est en attente de modération avant sa mise en ligne.'
                                    : 'Votre modèle est enregistré comme contenu masqué.',
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.back();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            }
                          },
                    child: controller.isLoading.value
                        ? circularProgress()
                        : Text(
                            controller.isPublic.value
                                ? '   Publier    '
                                : 'Enregistrer',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

Future<bool> _showPublishReview(
  BuildContext context,
  AjoutModeleController controller,
) async {
  if (controller.images.isEmpty) {
    showCustomSnackbar(
        message: 'Ajoutez au moins une image avant de continuer.');
    return false;
  }

  String categoryName = 'Catégorie non sélectionnée';
  for (final category in controller.categorieList) {
    if (category.id == controller.selectedCategoryId.value) {
      categoryName = category.libelle;
      break;
    }
  }

  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => _PublishReviewSheet(
          controller: controller,
          categoryName: categoryName,
        ),
      ) ??
      false;
}

class _PublishReviewSheet extends StatelessWidget {
  const _PublishReviewSheet({
    required this.controller,
    required this.categoryName,
  });

  final AjoutModeleController controller;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final description = controller.detailTextController.text.trim();
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vérifier avant de publier',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Votre contenu sera soumis avec les informations suivantes.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(controller.images.first.path),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReviewRow(
                          label: 'Images',
                          value: '${controller.images.length}'),
                      _ReviewRow(label: 'Catégorie', value: categoryName),
                      _ReviewRow(
                        label: 'Visibilité',
                        value: controller.isPublic.value
                            ? 'Public après modération'
                            : 'Masqué',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: Icon(controller.isPublic.value
                    ? Icons.send_rounded
                    : Icons.save_outlined),
                label: Text(controller.isPublic.value
                    ? 'Soumettre à la modération'
                    : 'Enregistrer sans publier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label : $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
