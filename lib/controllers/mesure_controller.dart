import 'package:faani/app_state.dart';
import 'package:faani/services/mesure_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MesureController {
  // get all mesure for a user
  void getAllUserModele(BuildContext context, String idUser) {
    MesureService().getAllUserMesure(idUser).listen((event) {
      if (event.isNotEmpty) {
        Provider.of<ApplicationState>(context, listen: false).mesuresList = event;
      }
    });
  }
}