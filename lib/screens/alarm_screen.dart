import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Status bar aur navigation bar hide karo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Blinking animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // ✅ Back button bilkul kaam nahi karega
      canPop: false,
      onPopInvoked: (didPop) {
        // Kuch mat karo — block hai
      },
      child: Scaffold(
        backgroundColor: Colors.red[900],
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Blinking Icon
                FadeTransition(
                  opacity: _animation,
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 120,
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                const Text(
                  '🚨 EMERGENCY ALERT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                // Subtitle
                const Text(
                  'Turant dhyan do!\nStop notification ka intezaar...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Loading indicator
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}