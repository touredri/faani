// import 'package:faani/app/data/models/client_model.dart';
// import 'package:faani/app/data/models/mesure_model.dart';
// import 'package:faani/app/data/models/categorie_model.dart';
// import 'package:faani/app/data/models/modele_model.dart';
// import 'package:faani/app/data/models/tailleur_model.dart';
// import 'package:flutter/material.dart';

// class CurrentUsers {
//   final String uid;
//   final String? nom;
//   final String? numero;
//   CurrentUsers({this.nom, this.numero, required this.uid});

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'nom': nom,
//       'numero': numero,
//     };
//   }
// }

// class ApplicationState extends ChangeNotifier {
//   bool isTailleur = false;
//   CurrentUsers? currentUsers;
//   bool isLoading = false;
//   List<Categorie> categorie = <Categorie>[];
//   List<Modele> listModeles = <Modele>[];
//   List<Mesure> listMesures = <Mesure>[];

//   set loadingState(bool load) {
//     isLoading = load;
//     ChangeNotifier();
//   }

//   set categories(List<Categorie> cat) {
//     categorie = cat;
//     ChangeNotifier();
//   }

//   set modeles(List<Modele> modele) {
//     listModeles = modele;
//     ChangeNotifier();
//   }

//   set mesuresList(List<Mesure> mesure) {
//     listMesures = mesure;
//     ChangeNotifier();
//   }

//   Tailleur currentTailleur = Tailleur(
//       quartier: '',
//       genreHabit: '',
//       isVerify: false,
//       nomPrenom: '',
//       telephone: 0,
//       genre: '',
//       id: '',
//       profile: '');

//   Client currentClient = Client(
//     nomPrenom: '',
//     telephone: 0,
//     genre: '',
//     id: '',
//   );

//   set changeTailleur(bool value) {
//     isTailleur = value;
//     notifyListeners();
//   }

//   set changeCurrentTailleur(Tailleur value) {
//     currentTailleur = value;
//     notifyListeners();
//   }

//   set changeCurrentClient(Client value) {
//     currentClient = value;
//     notifyListeners();
//   }

//   set changeCurrentUser(CurrentUsers? value) {
//     currentUsers = value;
//     notifyListeners();
//   }
// }
