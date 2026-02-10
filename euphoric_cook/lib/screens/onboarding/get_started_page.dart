import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch, size: 100, color: AppColors.vibrantOrange),
          const SizedBox(height: 20),
          const Text(
            'Ready to Cook?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Let\'s get started! 🔥'),
        ],
      ),
    );
  }
}