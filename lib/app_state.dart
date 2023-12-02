import 'package:faani/modele/mesure.dart';
import 'package:flutter/material.dart';
import 'modele/classes.dart';

class CurrentUsers {
  final String uid;
  final String? nom;
  final String? numero;
  CurrentUsers({this.nom, this.numero, required this.uid});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nom': nom,
      'numero': numero,
    };
  }
}


class ApplicationState extends ChangeNotifier {
  bool isLastPage = false;
  Measure? _measure;
  bool isTailleur = false;

  CurrentUsers? currentUsers;

  Tailleur currentTailleur = Tailleur(
    quartier: '',
    genreHabit: '',
    isVerify: false,
    nomPrenom: '',
    telephone: 0,
    genre: '',
    id: '',
  );

  Client currentClient = Client(
    nomPrenom: '',
    telephone: 0,
    genre: '',
    id: '',
  );

  set lastPage(bool value) {
    isLastPage = value;
    notifyListeners();
  }

  Measure? get measure => _measure;

  set mesure(Measure? value) {
    _measure = value;
    notifyListeners();
  }

  set changeTailleur(bool value) {
    isTailleur = value;
    notifyListeners();
  }

  set changeCurrentTailleur(Tailleur value) {
    currentTailleur = value;
    notifyListeners();
  }

  set changeCurrentClient(Client value) {
    currentClient = value;
    notifyListeners();
  }

  set changeCurrentUser(CurrentUsers? value) {
    currentUsers = value;
    notifyListeners();
  }
}
