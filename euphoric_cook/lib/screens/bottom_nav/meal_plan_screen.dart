import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For nice date formatting
import '../../constants/colors.dart';

class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  late DateTime today;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    selectedDate = today;
  }

  @override
  Widget build(BuildContext context) {
    final normalizedToday = DateTime(today.year, today.month, today.day);

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
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = normalizedToday.add(Duration(days: index));
                  final isSelected =
                      selectedDate != null && day.isAtSameMomentAs(selectedDate!);
                  final weekday = DateFormat('EEE').format(day); // Mon, Tue...
                  final dateNum = DateFormat('d').format(day);

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = day;
                        });
                      },
                      child: Card(
                        elevation: isSelected ? 6 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: isSelected
                            ? AppColors.vibrantOrange
                            : AppColors.cardBgLight,
                        child: SizedBox(
                          width: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weekday,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.lightText
                                      : AppColors.darkText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateNum,
                                style: TextStyle(
                                  fontSize: 28,
                                  color: isSelected
                                      ? AppColors.lightText
                                      : AppColors.darkText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.lightText,
                                    size: 20,
                                  ),
                                ),
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
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppColors.lightText),
                      label: const Text(
                        'Create Meal Plan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      icon: const Icon(Icons.track_changes,
                          color: AppColors.lightText),
                      label: const Text(
                        'Track Meal',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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

            const SizedBox(height: 24),

            // 3. Selected Date Display
            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Date: ${DateFormat('EEEE, MMM d, yyyy').format(selectedDate!)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Placeholder for future content
            Expanded(
              child: Center(
                child: Text(
                  'Your meal plans will appear here',
                  style:
                  TextStyle(color: AppColors.darkText.withOpacity(0.6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
