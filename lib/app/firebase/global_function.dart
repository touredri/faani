import 'dart:convert';
import 'dart:math';
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

