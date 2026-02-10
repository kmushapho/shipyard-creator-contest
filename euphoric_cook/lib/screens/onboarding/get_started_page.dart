import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF8C42), Color(0xFFFF6B3D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch, size: 100, color: AppColors.lightBg),
                const SizedBox(height: 20),
                const Text(
                  'Ready to Cook?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightBg,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Let\'s get started! 🔥',
                  style: TextStyle(fontSize: 16, color: AppColors.lightBg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
