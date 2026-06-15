import 'dart:convert';
import 'package:cts_customer/modules/screens/notification_detail/notification_detail_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../data/local/db_helper.dart';
import '../modules/models/notification/notification_model.dart';
import '../modules/controllers/notification/notification_history_controller.dart';

// This must be a top-level function (outside the class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize DB and save even if app is closed
  final db = DbHelper();
  RemoteNotification? notification = message.notification;
  if (notification != null) {
    await db.insertNotification(NotificationModel(
      title: notification.title ?? 'No Title',
      body: notification.body ?? 'No Body',
      time: DateTime.now().toIso8601String(),
      isRead: false,
    ));
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Request Permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            Map<String, dynamic> data = jsonDecode(response.payload!);
            _navigateToDetailFromData(data);
          } catch (e) {
            debugPrint("Error parsing local notification payload: $e");
          }
        }
      },
    );

    // 3. Create Android Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 
      'High Importance Notifications', 
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final dynamic plugin = _localNotificationsPlugin;
        await plugin.resolvePlatformSpecificPlugin<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      } catch (e) {
        debugPrint("Error creating notification channel: $e");
      }
    }

    // 4. Handle Notification Clicks
    _handleNotificationClick();

    // 5. Listen for Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        // Save to Local Database in Foreground
        await DbHelper().insertNotification(NotificationModel(
          title: notification.title ?? 'No Title',
          body: notification.body ?? 'No Body',
          time: DateTime.now().toIso8601String(),
          isRead: false,
        ));

        // LIVE REFRESH: Update count on dashboard if app is open
        if (Get.isRegistered<NotificationHistoryController>()) {
          Get.find<NotificationHistoryController>().fetchNotifications();
        }

        // Pack all data into payload
        Map<String, dynamic> data = Map.from(message.data);
        data['title'] = data['title'] ?? notification.title;
        data['message'] = data['message'] ?? data['body'] ?? notification.body;

        String payload = jsonEncode(data);
        
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: payload,
        );
      }
    });
  }

  static void _handleNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateToDetail(message);
    });

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 3500), () {
          _navigateToDetail(message);
        });
      }
    });
  }

  static void _navigateToDetail(RemoteMessage message) {
    _navigateToDetailFromData(message.data, notification: message.notification);
  }

  static void _navigateToDetailFromData(Map<String, dynamic> data, {RemoteNotification? notification}) {
    String title = data['title'] ?? notification?.title ?? 'No Title';
    String content = data['message'] ?? data['body'] ?? notification?.body ?? 'No Message';

    Get.off(
      () => const NotificationDetailScreen(),
      arguments: {
        'id': data['id']?.toString() ?? '',
        'title': title,
        'message': content,
      },
      preventDuplicates: false,
    );
  }
}
