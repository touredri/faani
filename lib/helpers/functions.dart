import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app_state.dart';
// import 'package:faani/modele/classes.dart';
import 'package:faani/models/client_model.dart';
import 'package:faani/models/tailleur_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final firestore = FirebaseFirestore.instance;

void definedCurrentUser(dynamic user, BuildContext context) {
  final appState = Provider.of<ApplicationState>(context, listen: false);
  CurrentUsers currentUsers = CurrentUsers(
          uid: user.id,
          numero: user.telephone.toString(),
          nom: user.nomPrenom);
      appState.changeCurrentUser = currentUsers;
}


  Future<void> handleTailleur(String uid,dynamic _user, BuildContext context) async {
    // Tailleur tailleur = _user;      

    final docRef = firestore.collection('Tailleur').doc(uid);
    final tailleur = Tailleur.fromMap(_user, docRef);
    final appState = Provider.of<ApplicationState>(context, listen: false);
    appState.changeCurrentTailleur = tailleur;
    definedCurrentUser(tailleur, context);
  }

  Future<void> handleClient(String uid,dynamic _user, BuildContext context) async {
    final docRef = firestore.collection('client').doc(uid);
    final client = Client.fromMap(_user, docRef);
    // Client client = Client.fromMap(map, docRef);
    final appState = Provider.of<ApplicationState>(context, listen: false);
    appState.changeCurrentClient = client;
    definedCurrentUser(client, context);
  }
