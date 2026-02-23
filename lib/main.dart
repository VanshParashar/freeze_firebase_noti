import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/alarm_screen.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'service/notification_service.dart';
import 'service/audio_service.dart';
import 'service/screen_lock_service.dart';

// ✅ Global Navigator Key — kahin se bhi navigate kar sako
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ✅ Background Handler — top level hona zaroori hai
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Type clearly check karo
  final String type = (message.data['type'] ?? '').toString().toLowerCase().trim();

  debugPrint('🔔 Background message mila');
  debugPrint('🔔 Type: "$type"');
  debugPrint('🔔 Data: ${message.data}');

  if (type == 'stop') {
    debugPrint('🛑 Background: STOP');
    await AudioService.stopAlarm();
    await ScreenLockService.releaseScreen();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  } else if (type == 'start') {
    debugPrint('🚨 Background: START');
    await AudioService.startAlarm();
    await ScreenLockService.lockScreen();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AlarmScreen()),
          (route) => false,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _requestPermissions();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (await Permission.systemAlertWindow.isDenied) {
    await Permission.systemAlertWindow.request();
  }

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _listenForegroundMessages();
    _getToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.initialize(context);
    });
  }

  // ✅ Foreground mein notification aane par
  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final type = message.data['type'] ?? 'start';

      if (type == 'stop') {
        AudioService.stopAlarm();
        ScreenLockService.releaseScreen();
        // Home par wapas jao
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      } else {
        AudioService.startAlarm();
        ScreenLockService.lockScreen();
        // AlarmScreen kholo
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AlarmScreen()),
              (route) => false,
        );
      }
    });
  }

  Future<void> _getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('==================================');
    debugPrint('FCM TOKEN: $token');
    debugPrint('==================================');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ✅ Global key connect karo
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}