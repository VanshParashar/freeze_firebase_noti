import 'package:firebse_freeze_app/service/screen_lock_service.dart';
import 'package:flutter/material.dart';

import 'alarm_screen.dart';
import '../service/audio_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Notification ka intezaar...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Test buttons
            ElevatedButton(
              onPressed: () {
                AudioService.startAlarm();
                ScreenLockService.lockScreen();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AlarmScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Test Start Alarm',
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                AudioService.stopAlarm();
                ScreenLockService.releaseScreen();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Test Stop Alarm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}