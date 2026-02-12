import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../providers/user_provider.dart';


class MealPlanSetupPage extends StatelessWidget {
  const MealPlanSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access user provider
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.name;
    final isDark = userProvider.isDarkMode;

    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardColor = isDark ? AppColors.cardBgDark : AppColors.cardBgLight;
    final textColor = isDark ? AppColors.lightText : AppColors.darkText;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Meal Plan Setup',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome / Teaser ──────────────────────────────
            Text(
              'Welcome, $userName! Ready to craft your perfect meals?',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // ── Step 1 – Smart Profile Confirmation ─────────────
            _buildCard(
              'Step 1: Profile Confirmation',
              'Confirm your dietary preferences, allergies, and foods to avoid.',
              cardColor,
              textColor,
            ),
            const SizedBox(height: 16),

            // ── Step 2 – Goals in Motion ───────────────────────
            _buildCard(
              'Step 2: Goals in Motion',
              'Select your health goals like weight loss, muscle gain, or energy.',
              cardColor,
              textColor,
            ),
            const SizedBox(height: 16),

            // ── Step 3 – Meal & Snack Frequency ───────────────
            _buildCard(
              'Step 3: Meal & Snack Frequency',
              'Choose which meals you want to include and their frequency.',
              cardColor,
              textColor,
            ),
            const SizedBox(height: 16),

            // ── Step 4 – Daily Nutrition Targets ──────────────
            _buildCard(
              'Step 4: Daily Nutrition Targets',
              'Set your calories, protein, carbs, fats, and water goals.',
              cardColor,
              textColor,
            ),
            const SizedBox(height: 16),

            // ── Step 5 – Cooking Time ─────────────────────────
            _buildCard(
              'Step 5: Cooking Time',
              'Select how much time you want to spend cooking each day.',
              cardColor,
              textColor,
            ),
            const SizedBox(height: 16),

            // ── Step 6 – Pantry & Meal Generation ─────────────
            _buildCard(
              'Step 6: Pantry & Meal Generation',
              'Add pantry items or generate suggested meals.',
              cardColor,
              textColor,
            ),
            const SizedBox(height: 24),

            // CTA Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Generate meals from pantry
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Add My Pantry & Generate →',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Generate meals automatically
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.vibrantOrange),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Generate Suggested Meals →',
                      style: TextStyle(
                        color: AppColors.vibrantOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
