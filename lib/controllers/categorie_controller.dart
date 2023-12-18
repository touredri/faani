import 'package:faani/app_state.dart';
import 'package:faani/models/categorie_model.dart';
import 'package:faani/services/categorie_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategorieController {
  void getCategorie(BuildContext context) {
    // List<Categorie> categorie = <Categorie>[];
    CategorieService().getCategorie().listen((event) {
      if (event.isNotEmpty) {
        Provider.of<ApplicationState>(context, listen: false).categories = event;
      }
    });
    // print("controller: $categorie");
    // return categorie;
  }

  // get categorie by id
  void getCategorieById(String id) {
    // final list = getCategorie();
    // return list.where((element) => element.id == id).first;
  }
}
