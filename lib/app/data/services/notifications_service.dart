import 'dart:convert';

import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/home/views/home_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class PushNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // final apiService = Get.find<ApiService>();

  Future<void> initializeFCM(BuildContext context) async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final Map<String, dynamic> data = jsonDecode(response.payload!);
          _handleMessageOpen(context, data);
        }
      },
    );

    // Request permission for iOS devices
    await _requestPermission();

    // Get the device token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
    // apiService.saveFcmToken(token!);

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print("Token refreshed: $newToken");
      // Send the new token to the backend if necessary
      // apiService.saveFcmToken(newToken);
      bool isUserLoggedin = auth.currentUser != null;
      if (isUserLoggedin) {
        // update user token
        await UserController().updateUserToken(token);
      }
    });

    // Handle foreground message display
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          "Message received: ${message.notification?.title}, ${message.notification?.body}");
      _showForegroundNotification(message);
    });

    // Handle when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          "Message opened: ${message.notification?.title}, ${message.notification?.body}");
      _handleMessageOpen(Get.context ?? context, message.data);
    });

    // Handle message when the app launches from a terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpen(Get.context ?? context, initialMessage.data);
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else {
      print("User denied permission");
    }
  }

  void _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'Faani',
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'Notification Payload Data',
    );
  }

  void _handleMessageOpen(BuildContext context, Map<String, dynamic>? data) {
    Get.to(() => const HomeView());
    Future.delayed(const Duration(milliseconds: 500), () {
      // Get.to(() => NotificationPage());
      data?.entries.forEach((entry) {
        print("Key: ${entry.key}, Value: ${entry.value}");
      });
    });
  }
}
