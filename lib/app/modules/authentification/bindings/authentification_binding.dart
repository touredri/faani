import 'package:get/get.dart';
import 'package:faani/app/data/services/session_coordinator.dart';
import 'package:faani/app/data/services/getx_session_coordinator.dart';
import '../../home/controllers/user_controller.dart';
import '../controllers/authentification_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SessionCoordinator>()) {
      Get.lazyPut<SessionCoordinator>(
        GetxSessionCoordinator.standard,
        fenix: true,
      );
    }
    Get.lazyPut<UserController>(
      () => UserController(),
      fenix: true,
    );
    Get.lazyPut<AuthController>(
      () => AuthController(
        sessionCoordinator: Get.find<SessionCoordinator>(),
      ),
    );
  }
}
