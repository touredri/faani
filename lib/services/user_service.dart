// method update for client
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app_state.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final firestore = FirebaseFirestore.instance;

class UserService {
  //update profile name
  Future<void> updateProfile(String id, BuildContext context,
      String propertyName, dynamic value) async {
    final collection =
        Provider.of<ApplicationState>(context, listen: false).isTailleur
            ? 'Tailleur'
            : 'client';
    final documentReference = firestore.collection(collection).doc(id);
    await documentReference.update({propertyName: value});
    if (propertyName == 'nomPrenom') {
      updateUserName(value);
    }
  }

// add to collection users
  Future<void> addUserWithCustomId(
      String id, Map<String, dynamic> userData) async {
    await firestore.collection('users').doc(id).set(userData);
  }
}
