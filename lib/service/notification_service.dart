import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../screens/alarm_screen.dart';
import 'audio_service.dart';
import '../screens/home_screen.dart';
import '../main.dart';
import 'screen_lock_service.dart';

// ✅ Must be top-level function for background handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final data = message.data;
  final type = data['type'] ?? 'start';

  if (type == 'stop') {
    await AudioService.stopAlarm();
  } else {
    await AudioService.startAlarm();
    await ScreenLockService.lockScreen();
    _showFullScreenNotification(message);
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotif =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    // --- Firebase Messaging ---
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, sound: true, badge: true);

    // Get FCM token (send to your server)
    String? token = await messaging.getToken();
    debugPrint('==================================');
    debugPrint('FCM TOKEN: $token');
    debugPrint('==================================');
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token Refreshed: $newToken');
    });
    // --- Local Notifications Setup ---
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (details) {
        // Handle tap
      },
    );

    // Create high-priority channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel',
      'Alarm Notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'), // res/raw/alarm.mp3
      enableVibration: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    _localNotif
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    // --- Foreground Messages ---
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // --- Background (app open) ---
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // --- Terminated state ---
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }
  static void _handleMessage(RemoteMessage message) {
    // ✅ Dono jagah se type check karo
    final String type = (message.data['type'] ??
        message.notification?.title ??
        'start').toString().toLowerCase().trim();

    debugPrint('📩 Message type: $type');
    debugPrint('📩 Full data: ${message.data}');
    debugPrint('📩 Notification: ${message.notification?.title}');

    if (type == 'stop') {
      debugPrint('🛑 STOP command mila');
      AudioService.stopAlarm();
      ScreenLockService.releaseScreen();
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } else {
      debugPrint('🚨 START command mila');
      AudioService.startAlarm();
      ScreenLockService.lockScreen();
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AlarmScreen()),
            (route) => false,
      );
    }
  }

  static Future<void> _showFullScreenNotification(RemoteMessage message) async {
    // Full screen intent wala page
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Emergency alarm notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,        // ← FULL SCREEN
      category: AndroidNotificationCategory.alarm,
      sound: RawResourceAndroidNotificationSound('alarm'),
      playSound: true,
      ongoing: true,                 // ← Swipe se dismiss nahi hogi
      autoCancel: false,
      visibility: NotificationVisibility.public,  // ← Lock screen par bhi dikhe
      enableVibration: true,
      enableLights: true,
    );

    await _localNotif.show(
      999,
      message.notification?.title ?? '🚨 Alert',
      message.notification?.body ?? 'Emergency!',
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> _cancelAlarmNotification() async {
    await _localNotif.cancel(999);
  }
}

// Top-level helper used by background handler too
Future<void> _showFullScreenNotification(RemoteMessage message) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'alarm_channel', 'Alarm Notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      sound: RawResourceAndroidNotificationSound('alarm'),
    ),
  );
  await plugin.show(999, message.notification?.title ?? 'Alert',
      message.notification?.body ?? '', details);
}