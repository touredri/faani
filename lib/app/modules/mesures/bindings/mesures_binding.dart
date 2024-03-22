import 'package:get/get.dart';

import '../controllers/mesures_controller.dart';

class MesuresBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MesuresController>(
      () => MesuresController(),
    );
  }
}
