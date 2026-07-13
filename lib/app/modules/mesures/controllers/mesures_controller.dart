import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/domain/mesures/mesure_draft.dart';
import 'package:faani/app/domain/mesures/mesure_field.dart';
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

  Mesure? currentMesure;

  void applyDraft(MesureDraft draft) {
    _setField(MesureField.epaule, draft.values[MesureField.epaule]);
    _setField(MesureField.bras, draft.values[MesureField.bras]);
    _setField(MesureField.hanche, draft.values[MesureField.hanche]);
    _setField(MesureField.longueur, draft.values[MesureField.longueur]);
    _setField(MesureField.poitrine, draft.values[MesureField.poitrine]);
    _setField(MesureField.taille, draft.values[MesureField.taille]);
    _setField(MesureField.ventre, draft.values[MesureField.ventre]);
    _setField(MesureField.poignet, draft.values[MesureField.poignet]);
  }

  MesureDraft buildDraft(int userHeightCm) {
    var draft = MesureDraft(userHeightCm: userHeightCm);
    for (final field in MesureField.values) {
      final value = int.tryParse(_controllerFor(field).text) ?? 0;
      if (value > 0) {
        draft = draft.copyWithValue(
          field: field,
          valueCm: value,
          source: MesureValueSource.manual,
        );
      }
    }
    return draft;
  }

  void resetController() {
    isLastPage.value = false;
    for (final field in MesureField.values) {
      _controllerFor(field).clear();
    }
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  TextEditingController _controllerFor(MesureField field) {
    switch (field) {
      case MesureField.epaule:
        return epauleController;
      case MesureField.bras:
        return brasController;
      case MesureField.hanche:
        return hancheController;
      case MesureField.longueur:
        return longeurController;
      case MesureField.poitrine:
        return poitrineController;
      case MesureField.taille:
        return tailleController;
      case MesureField.ventre:
        return ventreController;
      case MesureField.poignet:
        return poignetController;
    }
  }

  void _setField(MesureField field, int? value) {
    if (value != null && value > 0) {
      _controllerFor(field).text = '$value';
    }
  }

  @override
  void onInit() {
    super.onInit();
    isLastPage.value = false;
  }

  @override
  void onClose() {
    epauleController.dispose();
    ventreController.dispose();
    poitrineController.dispose();
    longeurController.dispose();
    hancheController.dispose();
    brasController.dispose();
    tailleController.dispose();
    poignetController.dispose();
    pageController.dispose();
    super.onClose();
  }
}
