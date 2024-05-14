import 'dart:io';
import 'dart:typed_data';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/ajout_modele/widgets/modele_form.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AjoutModeleController extends GetxController {
  final images = RxList<XFile>();
  final PageController pageController = PageController();
  RxString selectedCategoryId = '1'.obs;
  RxString selectedGender = 'Homme'.obs;
  RxBool isPublic = false.obs;
  List<Categorie> categorieList = <Categorie>[];
  final TextEditingController detailTextController = TextEditingController();

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
    final List<XFile> newImages = [];
    // final int totalModeleCount = await ModeleService().getTotalModeleCount();
    for (final XFile image in pickedImages) {
      final Uint8List bytes = await image.readAsBytes();
      final editedImage = await pushWithoutNavBar(
        context,
        MaterialPageRoute(builder: (context) => ImageEditor(image: bytes)),
      );
      if (editedImage != null) {
        // Save the edited image to a temporary file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/modele${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(editedImage);
        newImages.add(XFile(tempFile.path));
      }
    }
    images.addAll(newImages);
    Get.to(() => const AjoutModeleForm(), transition: Transition.zoom);
    update();
  }

  Future<List<Map<String, String>>> uploadImages(List<File> image) async {
    List<Map<String, String>> imageInfo = [];
    for (var image in image) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('modeles')
          .child(image.path.split('/').last);
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      imageInfo.add({
        'downloadUrl': url,
        'path': ref.fullPath,
      });
    }
    return imageInfo;
  }

  void createModel() async {
    List<File> imageFiles = images.map((e) => File(e.path)).toList();
    List<Map<String, String>> imageInfo = await uploadImages(imageFiles);
    final Modele modele = Modele(
        id: '',
        detail: detailTextController.text.isNotEmpty
            ? detailTextController.text
            : 'Description non disponible pour le moment',
        fichier: imageInfo.map((info) => info['downloadUrl']).toList(),
        imagePath: imageInfo.map((info) => info['path']).toList(),
        genreHabit: selectedGender.value,
        idTailleur: user!.uid,
        idCategorie: selectedCategoryId.value,
        isPublic: isPublic.value);
    await modele.create();
    images.clear();
  }

  void fetchCategories() async {
    CategorieService().getCategorie().listen((event) {
      for (var element in event) {
        categorieList.add(element);
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.find<ConnectivityController>().isOnline.value == false) {
      Get.snackbar(
          'Pas d\'accès internet ', 'Please check your internet connection',
          snackPosition: SnackPosition.TOP);
    }
    fetchCategories();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    categorieList.clear();
  }
}
