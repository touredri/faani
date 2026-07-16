import 'dart:convert';

import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/routes/app_pages.dart';
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
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      UserService().updateUserToken(userId, token);
    }
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint("Token refreshed: $newToken");
      final refreshedUserId = auth.currentUser?.uid;
      if (refreshedUserId != null) {
        UserService().updateUserToken(refreshedUserId, newToken);
      }
    });

    // Handle foreground message display
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          "Message received: ${message.notification?.title}, ${message.notification?.body}");
      _showForegroundNotification(message);
    });

    // Handle when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
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
      debugPrint("User granted permission");
    } else {
      debugPrint("User denied permission");
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
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageOpen(BuildContext context, Map<String, dynamic>? data) {
    final notificationId = data?['notificationId']?.toString() ?? '';
    if (notificationId.isNotEmpty) {
      Get.toNamed(Routes.notifications);
      return;
    }
    Get.toNamed(Routes.home);
    Future.delayed(const Duration(milliseconds: 500), () {
      // Get.to(() => NotificationPage());
      data?.entries.forEach((entry) {
        debugPrint("Key: ${entry.key}, Value: ${entry.value}");
      });
    });
  }
}
