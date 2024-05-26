import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:get/get.dart';
import '../../../data/models/users_model.dart';
import '../../../data/services/users_service.dart';
import '../../../firebase/global_function.dart';

class DetailModeleController extends GetxController {
  RxBool isAuthor = false.obs;
  final modeleUser = UserModel(nomPrenom: '', phoneNumber: '').obs;
  final Rx<Modele?> currentModele = Rx<Modele?>(null);
  final userController = Get.find<UserController>();

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
