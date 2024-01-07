import 'package:faani/app_state.dart';
import 'package:faani/models/modele_model.dart';
import 'package:faani/services/modele_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModeleController {
  Modele? modele;
  // CRUD modele
  void create(Modele modele) async {
    await ModeleService().create(modele);
  }

  void update(Modele modele) async {
    await ModeleService().update(modele);
  }

  void delete(String id) async {
    await ModeleService().delete(id);
  }

  //get a modele by id
  void getModeleById(String id) async {
    modele = await ModeleService().getModeleById(id);
  }

  // get all modele
  void getAllModeles(BuildContext context) {
    ModeleService().getAllModeles().listen((event) {
      if (event.isNotEmpty) {
        Provider.of<ApplicationState>(context, listen: false).modeles = event;
      }
    });
  }

// get all modele by categorie
  List<Modele> getAllModelesByCategorie(String idCategorie) {
    List<Modele> modeles = <Modele>[];
    ModeleService().getAllModelesByCategorie(idCategorie).listen((event) {
      if (event.isNotEmpty) {
        modeles = event;
      }
    });
    return modeles;
  }

// get a tailleur' all modele
  List<Modele> getAllModeleByTailleurId(String id) {
    List<Modele> modeles = <Modele>[];
    ModeleService().getAllModeleByTailleurId(id).listen((event) {
      if (event.isNotEmpty) {
        modeles = event;
      }
    });
    return modeles;
  }
}
