import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'package:faani/app/data/services/modele_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModeleService>(
      () => ModeleService(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
