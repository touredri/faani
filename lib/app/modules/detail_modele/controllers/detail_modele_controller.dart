import 'package:get/get.dart';
import '../../../data/models/users_model.dart';
import '../../../data/services/users_service.dart';
import '../../../firebase/global_function.dart';

class DetailModeleController extends GetxController {
  RxBool isAuthor = false.obs;
  final modeleUser = UserModel(nomPrenom: '', phoneNumber: '').obs;

  // get modele owner
  Future<void> getModeleOwner(String idUser) async {
    final user = await UserService().getUser(idUser);
    modeleUser.value = user;
    if (auth.currentUser!.uid == idUser) {
      isAuthor.value = true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.find<ConnectivityController>().isOnline.value == false) {
      Get.snackbar(
          'Pas d\'accès internet ', 'Please check your internet connection',
          snackPosition: SnackPosition.TOP);
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
