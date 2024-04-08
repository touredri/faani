import 'dart:math';

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
