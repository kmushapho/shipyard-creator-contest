import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 100, color: AppColors.vibrantOrange), // Cartoonish icon
          const SizedBox(height: 20),
          const Text(
            'Welcome to Euphoric Cook!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 10),
          const Text('Fun recipes await! 🍊', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}