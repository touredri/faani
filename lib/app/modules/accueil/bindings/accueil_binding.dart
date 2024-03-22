import 'package:get/get.dart';

import '../controllers/accueil_controller.dart';

class AccueilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccueilController>(
      () => AccueilController(),
    );
  }
}
