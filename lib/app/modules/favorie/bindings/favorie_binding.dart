import 'package:get/get.dart';

import '../controllers/favorie_controller.dart';

class FavorieBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavorieController>(
      () => FavorieController(),
    );
  }
}
