import 'package:get/get.dart';
import '../../home/controllers/user_controller.dart';

class ProfileController extends GetxController {
  UserController userController = Get.find();
  RxString selectedClientCible = ''.obs;
  RxString selectedCategorie = ''.obs;
  RxBool isTailleur = false.obs;
  RxString selectedLanguage = 'Français'.obs;
  final List<String> languages = [
    'Espagnol',
    'Allemand',
    'Italien',
    'Portugais',
    'Russe',
    'Chinois',
    'Japonais',
    'Arabe'
  ];

  // change language
  void updateLanguage(String language) {
    selectedLanguage.value = language;
  }

  @override
  void onInit() {
    super.onInit();
    if(userController.isTailleur.value) {
      isTailleur.value = true;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
