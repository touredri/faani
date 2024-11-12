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
      UserModel user = await UserService().getUser(auth.currentUser!.uid);
      if (user.nomPrenom != null) {
        currentUser.value = user;
        isTailleur.value = user.isTailleur;
      } else {
        currentUser.value =
            UserModel(nomPrenom: 'Annonymous', phoneNumber: 'Annonymous');
      }
    }
  }

  updateUserToken(String? token) {
    if (auth.currentUser != null) {
      UserService().updateUserToken(auth.currentUser!.uid, token);
    }
  }
}
