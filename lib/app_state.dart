import 'dart:math';

import 'package:flutter/material.dart';

class ApplicationState extends ChangeNotifier {
  int _currentValue = 0;
  bool isLastPage = false; 
  int get currentValue => _currentValue;

  set currentValue(int value) {
    _currentValue = value;
    notifyListeners();
  }

  set lastPage(bool value) {
    isLastPage = value;
    notifyListeners();
  }

  void increment() {
    _currentValue++;
    notifyListeners();
  }

  void decrement() {
    _currentValue = max(1, _currentValue - 1);
    notifyListeners();
  }

  void reset() {
    _currentValue = 0;
    notifyListeners();
  }
}
