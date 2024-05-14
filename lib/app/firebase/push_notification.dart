import 'dart:convert';

import 'package:faani/app/data/services/notifications_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/views/home_view.dart';
import 'package:faani/app/modules/message/views/message_view.dart';
import 'package:faani/app/modules/profile/views/notification_view.dart';
import 'package:faani/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {}
}

Future<void> initializePushNotifications() async {
  await PushNotifications().init(); // initialize firebase messaging
  await PushNotifications
      .localNotificationInit(); // initialize local notifications

  void handleRedirection(RemoteMessage message) {
    print('***************** ${message.notification!.title}');
    if (auth.currentUser != null) {
      if (message.notification!.title == 'Message' &&
          Get.currentRoute != '/message') {
        print('message view ******************************');
        Get.to(() => const MessageView());
      } else if (message.notification!.title == 'Notification' &&
          Get.currentRoute != '/discussion') {
        print('notification view ******************************');
        Get.to(() => const NotificationView());
      } else {
        print('home view ******************************');
        Get.offAllNamed('/home');
      }
    }
  }

  FirebaseMessaging.onBackgroundMessage(
      _firebaseBackgroundMessage); // handle background messages

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleRedirection(message);
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String arguments = jsonEncode(message.data);
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: arguments);
    }
  });

  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    Future.delayed(const Duration(seconds: 1), () {
      handleRedirection(initialMessage);
    });
  }
}
