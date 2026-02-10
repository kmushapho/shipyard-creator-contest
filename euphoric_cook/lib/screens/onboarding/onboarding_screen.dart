import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/colors.dart'; // Adjust path if your AppColors is elsewhere
import '../home_screen.dart'; // Path to your HomeScreen

// Import these if using (we'll define them in Step 2)
import 'welcome_page.dart';
import 'auth_page.dart';
import 'features_page.dart';
import 'get_started_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(); // Controls swiping
  int _currentPage = 0; // Tracks which slide you're on

  // Function to finish onboarding and go to home
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg, // Light background from your colors
      body: SafeArea(
        child: Stack(
          children: [
            // The swiper for slides
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: const [
                WelcomePage(),
                AuthPage(),
                FeaturesPage(),
                GetStartedPage(),
              ],
            ),

            // Bottom dots and button (fixed on screen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Dots to show progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => _buildDot(i == _currentPage)),
                  ),
                  const SizedBox(height: 20),

                  // Next/Skip button
                  if (_currentPage < 4)
                    ElevatedButton(
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 18)),
                    )
                  else
                    ElevatedButton(
                      onPressed: _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('Get Started!', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                ],
              ),
            ),

            // Skip button on top right (for early slides)
            if (_currentPage < 4)
              Positioned(
                top: 20,
                right: 20,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text('Skip', style: TextStyle(color: AppColors.vibrantOrange)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper for dots
  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.vibrantOrange : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}