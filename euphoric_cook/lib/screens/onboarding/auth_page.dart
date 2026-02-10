import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.vibrantOrange, // main background
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            40,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Title
              const Text(
                "Welcome Back or Join the Fun",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Google button (white bg, subtle orange)
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.vibrantOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.g_mobiledata, size: 26),
                label: const Text("Continue with Google"),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "or",
                  style: TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 20),

              // Email field
              _inputField(hint: "Your email", icon: Icons.email, obscure: false),

              const SizedBox(height: 15),

              // Password field
              _inputField(hint: "Password", icon: Icons.lock, obscure: true),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login button (light cream/off-white, stands out against orange)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA87D), // lighter orange
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Log In"),
              ),

              const SizedBox(height: 12),

              // Sign Up button (soft burnt orange)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDB5A28),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Sign Up"),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "By signing up you agree to Terms & Privacy",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required IconData icon,
    required bool obscure,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.vibrantOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
