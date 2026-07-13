import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/session_coordinator.dart';
import 'package:faani/app/data/services/getx_session_coordinator.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';

class HomeBinding extends Bindings {
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
    Get.lazyPut<ModeleService>(
      () => ModeleService(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
