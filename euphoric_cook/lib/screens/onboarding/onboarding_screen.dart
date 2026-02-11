import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/colors.dart'; // Adjust path if your AppColors is elsewhere
import '../bottom_nav/home_screen.dart'; // Path to your HomeScreen

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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final int _totalPages = 4;

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
    final bool isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView with onboarding slides
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: const [
                WelcomePage(),
                FeaturesPage(),
                GetStartedPage(),
                AuthPage(),
              ],
            ),

            // Bottom dots + Next button → HIDDEN on AuthPage
            if (!isLastPage)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Progress Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _totalPages,
                            (i) => _buildDot(i == _currentPage),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Next Button
                    ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // breathing room at bottom
                  ],
                ),
              ),

            // Skip button → also hidden on last page
            if (!isLastPage)
              Positioned(
                top: 20,
                right: 20,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: AppColors.lightText),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

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