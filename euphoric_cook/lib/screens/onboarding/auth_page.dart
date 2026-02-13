import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/colors.dart';
import '../bottom_nav/home_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoadingGuest = false;
  bool _isLoadingGoogle = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Guest login
  Future<void> _continueAsGuest() async {
    if (_isLoadingGuest) return;
    setState(() => _isLoadingGuest = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } finally {
      if (mounted) setState(() => _isLoadingGuest = false);
    }
  }

  // Google login
  Future<void> _loginWithGoogle() async {
    if (_isLoadingGoogle) return;
    setState(() => _isLoadingGoogle = true);

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // cancelled

      final auth = await account.authentication;
      final idToken = auth.idToken;

      final response = await http.post(
        Uri.parse('https://euphoric-backend.onrender.com/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('User verified: ${data['email']}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background
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
          ),

          // Form
          SafeArea(
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
                            onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ],
                        const SizedBox(height: 30),
                        _buildEmailButton(),
                        const SizedBox(height: 15),
                        _buildGoogleButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Guest button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoadingGuest ? null : _continueAsGuest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoadingGuest
                      ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantOrange),
                    ),
                  )
                      : const Text(
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
          icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
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

  Widget _buildEmailButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Add email/password login/signup logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email login/signup not implemented')),
          );
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

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(Icons.g_mobiledata_sharp, color: Colors.blue, size: 26),
        label: const Text('Sign in with Google'),
        onPressed: _loginWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
      ),
    );
  }
}
