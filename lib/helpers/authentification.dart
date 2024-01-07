import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app_state.dart';
import 'package:faani/models/client_model.dart';
import 'package:faani/models/tailleur_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;

void authWithPhoneNumber(String phone,
    {required Function(String value, int? value1) onCodeSend,
    // required Function(PhoneAuthCredential value) onAutoVerify,
    required Function(FirebaseAuthException value) onFailed,
    required Function(String value) autoRetrieval}) async {
  _auth.verifyPhoneNumber(
    phoneNumber: phone,
    timeout: const Duration(seconds: 20),
    // verificationCompleted: onAutoVerify,
    verificationFailed: onFailed,
    codeSent: onCodeSend,
    codeAutoRetrievalTimeout: autoRetrieval,
    verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {},
  );
}

Future<void> validateOtp(String smsCode, String verificationId) async {
  final credential = PhoneAuthProvider.credential(
      verificationId: verificationId, smsCode: smsCode);
  await _auth.signInWithCredential(credential);
  return;
}

Future<void> disconnect() async {
  await _auth.signOut();
  return;
}

User? get user => _auth.currentUser;

void sendOtpCode() {
  // loading = true;
  // setState(() {});
  // final firestore = FirebaseFirestore.instance;
  // if (phoneNumber.isNotEmpty) {
  // authWithPhoneNumber(phoneNumber, onCodeSend: (verificationId, v) {
  //   loading = false;
  //   if (mounted) {
  //     setState(() {});
  //     Navigator.of(context).push(MaterialPageRoute(
  //         builder: (c) => Verification(
  //               verificationId: verificationId,
  //               phoneNumber: phoneNumber,
  //             )));
  //   }
  // }, onFailed: (e) {
  //   loading = false;
  //   if (mounted) {
  //     setState(() {});
  //   }
  //   print("Le code est erroné ffffffffffffffffffffffffffffffffffffffffffffff");
  //   debugPrint(e.toString());
  // }, autoRetrieval: (v) {});

  // take generated code
  // final code = generateSixDigitCode();
  // save code in firestore
  // firestore.collection('OTP').add({
  //   'code': code,
  //   'numero': phoneNumber,
  // });
  // loading = false;
  // if (mounted) {
  //   // setState(() {});
  //   Navigator.of(context).push(MaterialPageRoute(
  //       builder: (c) => Verification(
  //             verificationId: code,
  //             phoneNumber: phoneNumber,
  //           )));
}
// }
// }

String generateSixDigitCode() {
  var rng = new Random();
  var code = '';
  for (var i = 0; i < 6; i++) {
    code += rng.nextInt(10).toString();
  }
  return code;
}

void _verifyPhoneNumber(BuildContext context) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  await _auth.verifyPhoneNumber(
    phoneNumber: '+22393734481',
    verificationCompleted: (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      print('Numéro de téléphone vérifié automatiquement');
    },
    verificationFailed: (FirebaseAuthException e) {
      print(
          'La vérification du numéro de téléphone a échoué. Cause: ${e.message}');
    },
    codeSent: (String verificationId, int? resendToken) {
      print('Le code de vérification a été envoyé');
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      print(
          'Le délai pour la récupération automatique du code de vérification est écoulé');
    },
  );
}

// sign up with email and password
Future<User?> signUpWithEmailPassword(String email, String password) async {
  try {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (result.user != null) {
      return result.user;
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return null;
}

Future<void> updateUserName(String displayName) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await user.updateDisplayName(displayName);
    await user.reload();
  }
}

Future<bool> isEmailAlreadyInUse(String email) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> signInMethods =
      await _auth.fetchSignInMethodsForEmail(email);
  return signInMethods.isNotEmpty;
}

// Save a boolean value to shared preferences
Future<void> saveBoolean(String key, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

// Load a boolean value from shared preferences
Future<bool?> loadBoolean(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}

// Save an object to shared preferences
Future<void> saveObject(String key, Object value) async {
  final prefs = await SharedPreferences.getInstance();
  String jsonString = jsonEncode(value);
  await prefs.setString(key, jsonString);
}

// Load an object from shared preferences
Future<Object?> loadObject(String key) async {
  final prefs = await SharedPreferences.getInstance();
  String? jsonString = prefs.getString(key);
  return jsonString != null ? jsonDecode(jsonString) : null;
}

// auth anonymous
Future<User?> signInAnonymously() async {
  try {
    final result = await _auth.signInAnonymously();
    if (result.user != null) {
      return result.user;
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return null;
}

final firestore = FirebaseFirestore.instance;
Future<String?> getNomIfExists(String docId) async {
  DocumentSnapshot docSnapshot =
      await firestore.collection('users').doc(docId).get();
  if (docSnapshot.exists) {
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    return data['nom'] as String?;
  } else {
    return null;
  }
}

// change the isTailleur value of a user
Future<void> updateStateValues(String number, BuildContext context) async {
  final appState = Provider.of<ApplicationState>(context, listen: false);
  await firestore
      .collection('Tailleur')
      .where('telephone', isEqualTo: int.parse(number))
      .get()
      .then((value) {
    if (value.docs.isNotEmpty) {
      Tailleur tailleur =
          Tailleur.fromMap(value.docs.first.data(), value.docs.first.reference);
      saveObject('user', tailleur.toMap());
      saveBoolean('isTailleur', true);
      return;
    }
  });

  await firestore
      .collection('client')
      .where('telephone', isEqualTo: int.parse(number))
      .get()
      .then((value) {
    if (value.docs.isNotEmpty) {
      Client client =
          Client.fromMap(value.docs.first.data(), value.docs.first.reference);
      saveObject('user', client.toMap());
      saveBoolean('isTailleur', false);
      CurrentUsers currentUsers = CurrentUsers(
          uid: client.id,
          numero: client.telephone.toString(),
          nom: client.nomPrenom);
      appState.changeCurrentUser = currentUsers;
    }
  });
}
