import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login or Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, // Add your Google login logic here
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.vibrantOrange),
              child: const Text('Continue with Google'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {}, // Add email login
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.vibrantOrange),
              child: const Text('Log In'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {}, // Add sign up
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.vibrantOrange),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}