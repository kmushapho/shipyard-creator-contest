import 'dart:ui';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); // Slow rotation for the background glow
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Base Gradient Background (Kept your colors)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8C42), Color(0xFFFF6B3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated Icon Container
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Modern Text Styling
                          Text(
                            "WELCOME TO",
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Euphoric Cook",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 2,
                            width: 40,
                            color: Colors.white, // Your bright blue as an accent
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Your joyful kitchen companion ✨",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for background "Loud" color accent glows
  Widget _buildGlowCircle(Color color, {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}
