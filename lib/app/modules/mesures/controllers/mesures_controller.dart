import 'package:faani/app/data/models/mesure_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MesuresController extends GetxController {
  RxBool isLastPage = false.obs;
  final PageController pageController = PageController(initialPage: 0);
  final TextEditingController epauleController = TextEditingController();
  final TextEditingController ventreController = TextEditingController();
  final TextEditingController poitrineController = TextEditingController();
  final TextEditingController longeurController = TextEditingController();
  final TextEditingController hancheController = TextEditingController();
  final TextEditingController brasController = TextEditingController();
  final TextEditingController tailleController = TextEditingController();
  final TextEditingController poignetController = TextEditingController();

  void resetController() {
    pageController.dispose();
    ventreController.text = '';
    epauleController.text = '';
    poitrineController.text = '';
    longeurController.text = '';
    hancheController.text = '';
    brasController.text = '';
    tailleController.text = '';
    poignetController.text = '';
  }

  Mesure? currentMesure;

  @override
  void onInit() {
    super.onInit();
    isLastPage.value = false;
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
