import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
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

Future<void> sendNotification(
  String token,
  String title,
  String body, {
  String category = 'general',
  String targetType = '',
  String targetId = '',
}) async {
  final normalizedToken = token.trim();
  final normalizedTitle = title.trim();
  final normalizedBody = body.trim();
  if (normalizedToken.isEmpty ||
      normalizedTitle.isEmpty ||
      normalizedBody.isEmpty) {
    return;
  }
  await FirebaseFirestore.instance.collection('notificationRequests').add({
    'tokens': [normalizedToken],
    'title': normalizedTitle,
    'body': normalizedBody,
    'category': category,
    'targetType': targetType,
    'targetId': targetId,
    'status': 'pending',
    'createdBy': auth.currentUser?.uid ?? '',
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> sendProgrammingNotification(
    String tToken, String cToken, String title, String body, DateTime date,
    {String targetType = '', String targetId = ''}) async {
  final tokens = [tToken.trim(), cToken.trim()]
      .where((token) => token.isNotEmpty)
      .toSet()
      .toList();
  if (tokens.isEmpty || title.trim().isEmpty || body.trim().isEmpty) return;
  await FirebaseFirestore.instance.collection('notificationRequests').add({
    'tokens': tokens,
    'title': title.trim(),
    'body': body.trim(),
    'category': 'order',
    'targetType': targetType,
    'targetId': targetId,
    'status': 'pending',
    'scheduledAt': Timestamp.fromDate(date),
    'createdBy': auth.currentUser?.uid ?? '',
    'createdAt': FieldValue.serverTimestamp(),
  });
}
