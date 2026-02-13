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
  bool _isLoadingEmail = false;

  String? _errorMessage;

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

      if (idToken == null) {
        throw Exception("No ID token received");
      }

      final response = await http.post(
        Uri.parse('https://euphoric-backend.onrender.com/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Google login success: ${data['email']}');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Google login failed';
        setState(() => _errorMessage = err);
      }
    } catch (e) {
      setState(() => _errorMessage = "Google login error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  // Email/Password Login or Register
  Future<void> _handleEmailAuth() async {
    setState(() {
      _errorMessage = null;
      _isLoadingEmail = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter email and password";
        _isLoadingEmail = false;
      });
      return;
    }

    if (!isLogin) {
      final confirm = _confirmPasswordController.text.trim();
      if (password != confirm) {
        setState(() {
          _errorMessage = "Passwords do not match";
          _isLoadingEmail = false;
        });
        return;
      }
      if (password.length < 6) {
        setState(() {
          _errorMessage = "Password must be at least 6 characters";
          _isLoadingEmail = false;
        });
        return;
      }
    }

    try {
      final endpoint = isLogin ? '/login' : '/register';
      final body = {
        'email': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse('https://euphoric-backend.onrender.com$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('${isLogin ? "Login" : "Register"} success');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        final errData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errData['error'] ?? 'Authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error: $e";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingEmail = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background gradient
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

          // Main content
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

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 30),
                        _buildEmailButton(),
                        const SizedBox(height: 16),
                        _buildGoogleButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Guest button at bottom
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
                      ? const SizedBox(
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

  Widget _buildEmailButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoadingEmail ? null : _handleEmailAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: _isLoadingEmail
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
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
        icon: const Icon(Icons.g_mobiledata_sharp, color: Colors.blue, size: 26),
        label: const Text('Sign in with Google'),
        onPressed: _isLoadingGoogle ? null : _loginWithGoogle,
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