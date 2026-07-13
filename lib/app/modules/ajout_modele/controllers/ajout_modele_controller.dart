import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/ajout_modele/widgets/modele_form.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjoutModeleController extends GetxController {
  final images = RxList<XFile>();
  final PageController pageController = PageController();
  RxString selectedCategoryId = '2'.obs;
  RxString selectedGender = 'Homme'.obs;
  RxBool isPublic = true.obs;
  RxBool isLoading = false.obs;
  RxList<Categorie> categorieList = <Categorie>[].obs;
  final TextEditingController detailTextController = TextEditingController();
  StreamSubscription? _categorySubscription;

  void pickOrTakeImage(BuildContext context, bool isMultiSelection) async {
    final ImagePicker picker = ImagePicker();
    final source = isMultiSelection ? ImageSource.gallery : ImageSource.camera;
    final List<XFile> pickedImages;
    if (isMultiSelection) {
      pickedImages = await picker.pickMultiImage();
    } else {
      final XFile? image = await picker.pickImage(source: source);
      pickedImages = image != null ? [image] : [];
    }
    if (pickedImages.isEmpty) return; // Handle no selection case
    if (!context.mounted) return;
    final List<XFile> newImages = [];
    for (final XFile image in pickedImages) {
      final Uint8List bytes = await image.readAsBytes();
      if (!context.mounted) return;
      final editedImage = await pushWithoutNavBar(
        context,
        MaterialPageRoute(builder: (context) => ImageEditor(image: bytes)),
      );
      if (editedImage != null) {
        final tempDir = await getTemporaryDirectory();
        final String tempPath =
            '${tempDir.path}/modele_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Compress image before saving
        final XFile? compressedFile =
            await FlutterImageCompress.compressAndGetFile(
          image.path,
          tempPath,
          quality: 80,
          minWidth: 1080,
          minHeight: 1080,
        );

        if (compressedFile != null) {
          newImages.add(compressedFile);
        } else {
          final tempFile = File(tempPath);
          await tempFile.writeAsBytes(editedImage);
          newImages.add(XFile(tempFile.path));
        }
      }
    }
    images.addAll(newImages);
    Get.to(() => const AjoutModeleForm(), transition: Transition.zoom);
    update();
  }

  Future<List<Map<String, String>>> uploadImages(List<File> imageFiles) async {
    List<Map<String, String>> imageInfo = [];
    final String uid = user?.uid ?? 'anonymous';
    for (var image in imageFiles) {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      final ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('models')
          .child(uid)
          .child(fileName);

      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      imageInfo.add({
        'downloadUrl': url,
        'path': ref.fullPath,
      });
    }
    return imageInfo;
  }

  Future<bool> createModel() async {
    if (images.isEmpty) {
      showCustomSnackbar(message: "Veuillez ajouter au moins une image !");
      return false;
    }

    if (user == null) {
      showCustomSnackbar(
          message: "Vous devez être connecté pour ajouter un modèle.");
      return false;
    }

    if (selectedGender.value.isEmpty || selectedCategoryId.value.isEmpty) {
      showCustomSnackbar(
          message: "Veuillez remplir tous les champs obligatoires !");
      return false;
    }

    isLoading.value = true;
    try {
      List<File> imageFiles = images.map((e) => File(e.path)).toList();
      List<Map<String, String>> imageInfo = await uploadImages(imageFiles);

      final Modele modele = Modele(
          id: '',
          detail: detailTextController.text.isNotEmpty
              ? detailTextController.text
              : 'Description non disponible pour le moment ! Le tailleur n\'a pas ajouté de description',
          fichier: imageInfo.map((info) => info['downloadUrl']).toList(),
          imagePath: imageInfo.map((info) => info['path']).toList(),
          genreHabit: selectedGender.value,
          idTailleur: user!.uid,
          idCategorie: selectedCategoryId.value,
          isApproved: false,
          isPublic: isPublic.value,
          createdAt: Timestamp.now());

      await modele.create();
      images.clear();
      detailTextController.clear();
      return true;
    } catch (e) {
      debugPrint('Error creating model: $e');
      showCustomSnackbar(
          message: "Une erreur est survenue lors de la création du modèle.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void fetchCategories() {
    _categorySubscription?.cancel();
    _categorySubscription = CategorieService().getCategorie().listen((event) {
      categorieList.assignAll(event);
      categorieList.removeWhere((cat) => cat.id == "1");
      categorieList.removeWhere((cat) => cat.id == "8");
    });
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    _categorySubscription?.cancel();
    categorieList.clear();
    super.onClose();
  }
}
