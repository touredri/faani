import 'package:get/get.dart';

import '../controllers/ajout_commande_controller.dart';

class AjoutCommandeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AjoutCommandeController>(
      () => AjoutCommandeController(),
    );
  }
}
