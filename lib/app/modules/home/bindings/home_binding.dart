import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // Get.put<UserController>(UserController());
  }
}
