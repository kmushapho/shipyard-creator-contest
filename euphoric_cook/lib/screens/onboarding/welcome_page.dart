import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌈 Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF8C42), Color(0xFFFF6B3D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // 🥕 Floating icons
        _floatingIcon(Icons.local_dining, top: 80, left: 30),
        _floatingIcon(Icons.spa, top: 140, right: 40),
        _floatingIcon(Icons.favorite, top: 200, left: 80),
        _floatingIcon(Icons.restaurant, bottom: 150, right: 50),
        _floatingIcon(Icons.ramen_dining, bottom: 80, left: 40),
        _floatingIcon(Icons.local_florist, top: 60, left: 200),

        // ❤️ Twinkling hearts
        Positioned(
          top: 220,
          left: 140,
          child: _twinkleIcon(Icons.favorite, Colors.pinkAccent),
        ),
        Positioned(
          top: 260,
          right: 120,
          child: _twinkleIcon(Icons.favorite, Colors.pinkAccent),
        ),

        // 👨‍🍳 Center content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _glowController,
                builder: (_, child) {
                  return Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 20 + _glowController.value * 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.restaurant_menu,
                        size: 90, color: Colors.white),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text(
                "Welcome to",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              AnimatedBuilder(
                animation: _glowController,
                builder: (_, child) {
                  return Transform.scale(
                    scale: 1 + (_glowController.value * 0.05),
                    child: Text(
                      "Euphoric Cook",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          Shadow(
                            blurRadius: 30,
                            color: Colors.orangeAccent.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text(
                "Your joyful kitchen companion ✨",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Floating icon helper
  Widget _floatingIcon(IconData icon,
      {double? top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: _BreathingIcon(icon: icon),
    );
  }



  // Twinkling heart helper
  Widget _twinkleIcon(IconData icon, Color color) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (_, double value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _BreathingIcon extends StatefulWidget {
  final IconData icon;
  const _BreathingIcon({required this.icon});

  @override
  State<_BreathingIcon> createState() => _BreathingIconState();
}

class _BreathingIconState extends State<_BreathingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true); // 🔁 LOOP

    _scale = Tween(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(widget.icon, color: Colors.white70, size: 26),
    );
  }
}
