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
import 'package:get/get.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AjoutModeleController extends GetxController {
  final images = RxList<XFile>();
  final PageController pageController = PageController();
  RxString selectedCategoryId = '2'.obs;
  RxString selectedGender = 'Homme'.obs;
  RxBool isPublic = true.obs;
  RxBool isLoading = false.obs;
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
          .child('images')
          .child('models')
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

  Future<void> createModel() async {
    isLoading.value = true;
    List<File> imageFiles = images.map((e) => File(e.path)).toList();
    List<Map<String, String>> imageInfo = await uploadImages(imageFiles);
    if (imageFiles.isEmpty ||
        imageFiles.length > 2 ||
        selectedGender.value.isEmpty ||
        selectedCategoryId.value.isEmpty) {
      showCustomSnackbar(message: "veuillez remplir tous les champs !!");
      return;
    }
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
        isPublic: isPublic.value);
    await modele.create();
    images.clear();
    isLoading.value = false;
  }

  void fetchCategories() async {
    CategorieService().getCategorie().listen((event) {
      for (var element in event) {
        categorieList.add(element);
      }
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
    super.onClose();
    categorieList.clear();
  }
}
