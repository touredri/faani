import 'dart:convert';

import 'package:faani/app/data/services/notifications_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
  }
}

Future<void> initializePushNotifications() async {
  await PushNotifications().init(); // initialize firebase messaging
  await PushNotifications
      .localNotificationInit(); // initialize local notifications
  FirebaseMessaging.onBackgroundMessage(
      _firebaseBackgroundMessage); // handle background messages
  // on Background totif tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (auth.currentUser != null) {
        Get.to(() => const FaaniApp());
      }
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String arguments = jsonEncode(message.data);
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
          title: 'Faani App',
          body: 'Test foreground notif',
          payload: arguments);
    }
  });

  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    Future.delayed(const Duration(seconds: 1), () {
      if (auth.currentUser != null) {
        Get.to(() => const FaaniApp());
      }
    });
  }
}
