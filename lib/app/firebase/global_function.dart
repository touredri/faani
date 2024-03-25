import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;
User? get user => auth.currentUser;

// photo url
String getRandomProfileImageUrl() {
  var randomId = Random().nextInt(1000);
  return 'https://robohash.org/$randomId';
}