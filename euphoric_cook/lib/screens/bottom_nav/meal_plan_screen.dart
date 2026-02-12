import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For nice date formatting

class AppColors {
  static const vibrantOrange = Color(0xFFFF6B35);
  static const vibrantGreen = Color(0xFF4CAF50);
  static const vibrantBlue = Color(0xFF4A90E2);
  static const darkText = Color(0xFF1A1A1A);
  static const lightText = Colors.white;
  static const lightBg = Color(0xFFFDFDFD);
  static const darkBg = Color(0xFF121212);
  static const cardBgLight = Colors.white;
  static const cardBgDark = Color(0xFF1E1E1E);
}

class MealPlannerPage extends StatelessWidget {
  const MealPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Normalize to start of day

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: const Text(
          'Meal Planner',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 7-Day Calendar Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'This Week',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 110, // Adjust for card height + padding
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = today.add(Duration(days: index));
                  final isToday = day.isAtSameMomentAs(today);
                  final weekday = DateFormat('EEE').format(day); // Mon, Tue...
                  final dateNum = DateFormat('d').format(day);

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Navigate to detailed day view or select for planning
                      },
                      child: Card(
                        elevation: isToday ? 6 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: isToday ? AppColors.vibrantOrange : AppColors.cardBgLight,
                        child: SizedBox(
                          width: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weekday,
                                style: TextStyle(
                                  color: isToday ? AppColors.lightText : AppColors.darkText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateNum,
                                style: TextStyle(
                                  fontSize: 28,
                                  color: isToday ? AppColors.lightText : AppColors.darkText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isToday)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.lightText,
                                    size: 20,
                                  ),
                                ),
                              // Later: Add small meal icons or "Planned" badge here
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 2. Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to Create Meal Plan screen/flow
                      },
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.lightText),
                      label: const Text(
                        'Create Meal Plan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantOrange,
                        foregroundColor: AppColors.lightText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to Track/Log Meal screen (quick add)
                      },
                      icon: const Icon(Icons.track_changes, color: AppColors.lightText),
                      label: const Text(
                        'Track Meal',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantGreen,
                        foregroundColor: AppColors.lightText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Placeholder for future content (e.g., current plan summary, meals list, etc.)
            Expanded(
              child: Center(
                child: Text(
                  'Your meal plans will appear here',
                  style: TextStyle(color: AppColors.darkText.withOpacity(0.6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}