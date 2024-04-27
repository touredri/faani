import 'package:faani/app/modules/ajout_modele/views/ajout_modele.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ajout_modele_controller.dart';

class AjoutModeleView extends GetView<AjoutModeleController> {
  const AjoutModeleView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AjoutModele();
  }
}
