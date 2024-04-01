import 'package:get/get.dart';
import '../../../data/models/users_model.dart';
import '../../../data/services/users_service.dart';
import '../../../firebase/global_function.dart';

class DetailModeleController extends GetxController {
  RxBool isAuthor = false.obs;
  final modeleUser = UserModel(nomPrenom: '', phoneNumber: '').obs;

  // get modele owner
  void getModeleOwner(String idUser) {
    UserService().getUser(idUser).then((value) {
      modeleUser.value = value;
    });
    // check if user is author
    if (auth.currentUser!.uid == idUser) {
      isAuthor.value = true;
    }
  }

  // Future<void> init() async {
  //   await get
  // }

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
