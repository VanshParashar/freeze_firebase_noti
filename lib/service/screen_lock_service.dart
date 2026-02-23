import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenLockService {
  static const MethodChannel _channel =
  MethodChannel('com.example.firebse_freeze_app/screen_lock');

  /// Freeze/wake the screen and show over lock screen
  static Future<void> lockScreen() async {
    // Keep screen ON and bright
    await WakelockPlus.enable();

    // Tell native Android to show over lock screen
    try {
      await _channel.invokeMethod('showOverLockScreen');
    } catch (_) {}
  }

  static Future<void> releaseScreen() async {
    await WakelockPlus.disable();
    try {
      await _channel.invokeMethod('hideOverLockScreen');
    } catch (_) {}
  }
}