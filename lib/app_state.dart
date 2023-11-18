import 'package:faani/modele/mesure.dart';
import 'package:flutter/material.dart';

class ApplicationState extends ChangeNotifier {
  bool isLastPage = false;
  Measure? _measure;

  set lastPage(bool value) {
    isLastPage = value;
    notifyListeners();
  }

  Measure? get measure => _measure;

  set mesure(Measure? value) {
    _measure = value;
    notifyListeners();
  }
}
