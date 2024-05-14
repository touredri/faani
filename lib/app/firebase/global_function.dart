import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final auth = FirebaseAuth.instance;
User? get user => auth.currentUser;

// photo url
String getRandomProfileImageUrl() {
  var randomId = Random().nextInt(1000);
  return 'https://robohash.org/$randomId';
}

// delete images in firestorage
Future<void> deleteImage(String imagePath) async {
  final firebaseStorageRef = FirebaseStorage.instance.ref().child(imagePath);
  await firebaseStorageRef.delete();
}

Future<void> sendNotification(String token, String title, String body) async {
  final url = Uri.parse('https://my-faani-admin.onrender.com/api/send');

  try {
    final response = await http.post(
      url,
      body: jsonEncode({
        'token': token,
        'title': title,
        'body': body,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.statusCode}');
    }
  } catch (error) {
    print('Error sending notification: $error');
  }
}

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final _connectionStatus = ConnectivityResult.none.obs;
  final RxBool isOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    try {
      var result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _connectionStatus.value = result.first;
    isOnline.value = result.first != ConnectivityResult.none;
    if (result.first == ConnectivityResult.none) {
      isOnline.value = false;
      // Get.snackbar(
      //   'Pas d\'accès internet',
      //   'Please check your internet connection',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: primaryColor,
      //   colorText: Colors.white,
      // );
    } else if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi)) {
      isOnline.value = true;
      // Get.snackbar(
      //   'Connected to mobile data',
      //   'Vous avez une connexion internet mobile',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: primaryColor,
      //   colorText: Colors.white,
      // );
    } else {
      isOnline.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    // _connectivity.onConnectivityChanged.cancel();
  }

  ConnectivityResult get connectionStatus => _connectionStatus.value;
}
