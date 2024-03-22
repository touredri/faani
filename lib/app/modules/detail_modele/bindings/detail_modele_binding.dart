import 'package:get/get.dart';

import '../controllers/detail_modele_controller.dart';

class DetailModeleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailModeleController>(
      () => DetailModeleController(),
    );
  }
}
