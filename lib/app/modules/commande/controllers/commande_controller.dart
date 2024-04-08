import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommandeController extends GetxController {
  final UserController userController = Get.find();
  RxBool isSearching = false.obs;
  TextEditingController textEditingController = TextEditingController();
  final UserService userService = UserService();
  final ModeleService modeleService = ModeleService();
  final SuiviEtatService suiviEtatService = SuiviEtatService();
  final String currentEtat = 'En cours';

  Future<List<dynamic>> fetchCommandeData(Commande commande) async {
    return Future.wait([
      userService.getUser(commande.idTailleur),
      commande.idUser.isNotEmpty
          ? userService.getUser(commande.idUser)
          : Future.value(null),
      modeleService.getModeleById(commande.idModele),
      suiviEtatService.getEtatLibelle(commande.id)
    ]);
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    update(['search']);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
