import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // --- TOGGLE SWITCH ---
                  _buildToggleSwitch(),
                  const SizedBox(height: 40),

                  // --- FORM CONTAINER ---
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isLogin ? 'Welcome Back!' : 'Create Account',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 25),

                        // Email Field
                        _buildTextField(Icons.email_outlined, 'Email'),
                        const SizedBox(height: 15),

                        // Password Field with Eye Toggle
                        _buildTextField(
                          Icons.lock_outline,
                          'Password',
                          isPassword: true,
                          isObscured: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),

                        // Confirm Password Field (Sign Up Only)
                        if (!isLogin) ...[
                          const SizedBox(height: 15),
                          _buildTextField(
                            Icons.lock_reset_outlined,
                            'Confirm Password',
                            isPassword: true,
                            isObscured: _obscureConfirmPassword,
                            onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ],

                        const SizedBox(height: 30),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, {bool isPassword = false, bool isObscured = false, VoidCallback? onToggle}) {
    return TextField(
      obscureText: isPassword ? isObscured : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        )
            : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      height: 55, width: 280,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 140, height: 55,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            ),
          ),
          Row(
            children: [
              _toggleButton('Login', true),
              _toggleButton('Sign Up', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool value) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLogin = value),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: isLogin == value ? AppColors.vibrantOrange : Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          isLogin ? 'Log In' : 'Sign Up',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
