import 'package:get/get.dart';

import '../controllers/ajout_modele_controller.dart';

class AjoutModeleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AjoutModeleController>(
      () => AjoutModeleController(),
    );
  }
}
