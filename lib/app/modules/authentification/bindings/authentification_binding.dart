import 'package:get/get.dart';
import '../../home/controllers/user_controller.dart';
import '../controllers/authentification_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(
      () => UserController(),
      fenix: true,
    );
    Get.lazyPut<AuthController>(
      () => AuthController(),
    );
  }
}
