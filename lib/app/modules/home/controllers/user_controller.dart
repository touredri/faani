import 'package:faani/app/data/models/user_role.dart';
import 'package:faani/app/data/services/access_control_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:get/get.dart';
import '../../../data/models/users_model.dart';

class UserController extends GetxController {
  RxBool isTailleur = false.obs;
  final Rx<AppUserRole> role = AppUserRole.client.obs;
  final currentUser = UserModel(nomPrenom: '', phoneNumber: '').obs;

  bool get isAdmin => role.value == AppUserRole.admin;

  Future<void> init() async {
    if (auth.currentUser != null) {
      // Récupération de l'utilisateur actuel et mis a jour de `user` et `isTailleur`
      UserModel user = await UserService().getUser(auth.currentUser!.uid);
      if (user.nomPrenom != null) {
        role.value = await AccessControlService().getCurrentUserRole();
        user.role = role.value;
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
