import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/suivi_etat_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommandeController extends GetxController {
  final UserController userController = Get.find();
  RxBool isSearching = false.obs;
  TextEditingController textEditingController = TextEditingController();
  final UserService userService = UserService();
  final ModeleService modeleService = ModeleService();
  final SuiviEtatService suiviEtatService = SuiviEtatService();
  final String currentEtat = 'En cours';
  final RxBool isExpanded = false.obs;
  final ScrollController scrollController = ScrollController();
  final List<Modele> modeles = [];
  Rx<XFile?> image = Rx<XFile?>(null);
  final Rx<Mesure?> mesure = Rx<Mesure?>(null);
  final RxString selectedDate = ''.obs;
  final TextEditingController prixController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  Future<List<dynamic>> fetchCommandeData(Commande commande) async {
    return Future.wait([
      userService.getUser(commande.idTailleur),
      commande.idUser.isNotEmpty
          ? userService.getUser(commande.idUser)
          : Future.value(null),
      modeleService.getModeleById(commande.idModele),
      suiviEtatService.getSuiviEtatByCommandeId(commande.id!)
    ]);
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    update(['search']);
  }

  Stream<List<Modele>> init() {
    return modeleService
        .getAllModeleByTailleurId(userController.currentUser.value.id!)
        .map((event) {
      modeles.addAll(event);
      return modeles;
    });
  }

  // The listener function that will be called when the user scrolls
  void _onScroll() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        modeles.isNotEmpty) {
      modeleService
          .getAllModeleByTailleurId(userController.currentUser.value.id!,
              lastModele: modeles.last)
          .listen((event) {
        modeles.addAll(event);
      });
    }
  }

  void clearForm() {
    image.value = null;
    selectedDate.value = '';
    mesure.value = null;
    nomController.clear();
    numeroController.clear();
    prixController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.removeListener(_onScroll);
    modeles.clear();
  }
}
