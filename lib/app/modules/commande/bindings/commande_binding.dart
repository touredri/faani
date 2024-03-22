import 'package:get/get.dart';

import '../controllers/commande_controller.dart';

class CommandeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommandeController>(
      () => CommandeController(),
    );
  }
}
