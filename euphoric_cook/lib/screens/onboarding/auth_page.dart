import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/colors.dart';
import '../bottom_nav/home_screen.dart'; // ← Make sure this import points to your HomeScreen

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // New: Function to handle guest continue
  Future<void> _continueAsGuest() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);

    if (!mounted) return;

    // Go directly to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );

    // Optional: show a quick toast/feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Continuing as guest...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background + scrollable content
          Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
                child: Column(
                  children: [
                    _buildToggleSwitch(),
                    const SizedBox(height: 40),

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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 25),

                          _buildTextField(Icons.email_outlined, 'Email'),

                          const SizedBox(height: 15),

                          _buildTextField(
                            Icons.lock_outline,
                            'Password',
                            isPassword: true,
                            isObscured: _obscurePassword,
                            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),

                          if (!isLogin) ...[
                            const SizedBox(height: 15),
                            _buildTextField(
                              Icons.lock_reset_outlined,
                              'Confirm Password',
                              isPassword: true,
                              isObscured: _obscureConfirmPassword,
                              onToggle: () => setState(
                                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),

                          _buildSubmitButton(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // space for guest button
                  ],
                ),
              ),
            ),
          ),

          // Fixed guest button at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                30,
                20,
                30,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: 55,
                child: TextButton(
                  onPressed: _continueAsGuest, // ← Now calls the new function
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(
                      color: AppColors.vibrantOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  // ── The rest remains the same ─────────────────────────────────────────────

  Widget _buildTextField(
      IconData icon,
      String hint, {
        bool isPassword = false,
        bool isObscured = false,
        VoidCallback? onToggle,
      }) {
    return TextField(
      obscureText: isPassword ? isObscured : false,
      controller: isPassword
          ? (hint == 'Confirm Password' ? _confirmPasswordController : _passwordController)
          : _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        )
            : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      height: 55,
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 140,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLogin == value ? AppColors.vibrantOrange : Colors.white,
            ),
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
        onPressed: () {
          // TODO: Add your real login / signup logic here later
          // For now you can leave it empty or show a snackbar
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          isLogin ? 'Log In' : 'Sign Up',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}