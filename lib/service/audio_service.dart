import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class AudioService {
  static AudioPlayer? _player;

  static Future<void> startAlarm() async {
    await _startForegroundTask();
    _player ??= AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.loop);
    await _player!.play(AssetSource('sounds/alarm.mp3'));
  }

  static Future<void> stopAlarm() async {
    await _player?.stop();
    _player?.dispose();
    _player = null;
    await FlutterForegroundTask.stopService();
  }

  static Future<void> _startForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_alarm',
        channelName: 'Alarm Running',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(          // ✅ Fix 2
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );

    if (await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.startService(
      notificationTitle: '🚨 Alert Active',
      notificationText: 'Tap to open app',
      callback: startCallback,
    );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(AlarmTaskHandler());
}
class AlarmTaskHandler extends TaskHandler {

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print("Service started at $timestamp");
  }

  @override
  Future<void> onEvent(DateTime timestamp) async {
    print("Event triggered at $timestamp");
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print("Service destroyed at $timestamp");
  }

  @override
  void onRepeatEvent(DateTime timestamp) {

    // TODO: implement onRepeatEvent
  }
}