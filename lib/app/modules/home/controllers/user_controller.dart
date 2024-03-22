import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:get/get.dart';
import '../../../data/models/users_model.dart';

class UserController extends GetxController {
  RxBool isTailleur = false.obs;
  final currentUser = UserModel(nomPrenom: '', phoneNumber: '').obs;

  Future<void> init() async {
    if (auth.currentUser != null) {
      // Récupération de l'utilisateur actuel et mis a jour de `user` et `isTailleur`
      UserModel userModel = await UserService().getUser(auth.currentUser!.uid);
      currentUser.value = userModel;
      isTailleur.value = userModel.isTailleur;
    }
  }
}
