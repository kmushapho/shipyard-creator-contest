import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';

class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  DateTime? _selectedDate;

  // ── Progress state (per selected day) ────────────────────────────────
  double waterMl = 0.0;           // current water in ml
  final double waterTargetMl = 2000.0;
  int mealsLogged = 0;            // number of meals logged for selected day
  final int mealsTarget = 3;      // example target (breakfast + lunch + dinner)

  // Steps – just a number for now (you can make it dynamic later)
  int steps = 5500;

  List<DateTime> getWeekDates() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  bool _isSelected(DateTime date) {
    if (_selectedDate == null) return _isToday(date);
    return date.year == _selectedDate!.year &&
        date.month == _selectedDate!.month &&
        date.day == _selectedDate!.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _addWater() {
    setState(() {
      waterMl += 250;
      if (waterMl > waterTargetMl) waterMl = waterTargetMl;
    });
  }

  // You would call this when user actually logs a meal (for now – manual trigger example)
  void _logMeal() {
    setState(() {
      if (mealsLogged < mealsTarget) {
        mealsLogged++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates();
    final effectiveSelectedDate = _selectedDate ?? DateTime.now();

    final waterProgress = waterMl / waterTargetMl;
    final mealsProgress = mealsLogged / mealsTarget;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        title: const Text(
          'Meal Planner',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Progress Card ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.vibrantOrange.withOpacity(0.95),
                      AppColors.vibrantOrange,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vibrantOrange.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Current Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main progress row: Water • Steps • Meals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Water circle + add button
                        Column(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: waterProgress.clamp(0.0, 1.0),
                                    backgroundColor: Colors.white.withOpacity(0.25),
                                    color: Colors.white,
                                    strokeWidth: 10,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${(waterMl / 1000).toStringAsFixed(1)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '/ 2L',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _addWater,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Water',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        // Steps (text only)
                        Column(
                          children: [
                            Icon(
                              Icons.directions_walk_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              steps.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Steps',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        // Meals circle
                        Column(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: mealsProgress.clamp(0.0, 1.0),
                                    backgroundColor: Colors.white.withOpacity(0.25),
                                    color: Colors.white,
                                    strokeWidth: 9,
                                  ),
                                  Text(
                                    '$mealsLogged',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Meals',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Bottom centered text
                    Center(
                      child: Text(
                        'Check your progress so far',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Calendar (unchanged from previous version)
              SizedBox(
                height: 96,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    final day = weekDates[index];
                    final selected = _isSelected(day);
                    final today = _isToday(day);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = day;
                          // Reset progress when changing day (in real app you'd load saved data)
                          waterMl = 0.0;
                          mealsLogged = 0;
                        });
                      },
                      child: Container(
                        width: 68,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.vibrantOrange
                              : AppColors.cardBgLight,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: selected
                              ? [
                            BoxShadow(
                              color: AppColors.vibrantOrange.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E().format(day).toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.darkText.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: selected ? Colors.white : AppColors.darkText,
                              ),
                            ),
                            if (today && !selected)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.vibrantOrange.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  DateFormat('EEEE, MMMM d').format(effectiveSelectedDate),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Meal cards (unchanged)
              _buildMealCard('Breakfast', AppColors.vibrantGreen),
              const SizedBox(height: 16),
              _buildMealCard('Lunch', AppColors.vibrantBlue),
              const SizedBox(height: 16),
              _buildMealCard('Dinner', AppColors.vibrantOrange),
              const SizedBox(height: 16),
              _buildMealCard('Snack', AppColors.vibrantGreen.withOpacity(0.8)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      // Optional: floating debug button to simulate logging a meal
      floatingActionButton: FloatingActionButton(
        onPressed: _logMeal,
        backgroundColor: AppColors.vibrantBlue,
        child: const Icon(Icons.restaurant_menu),
        tooltip: 'Simulate log meal (debug)',
      ),
    );
  }

  Widget _buildMealCard(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBgLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.add_circle_outline_rounded,
                color: color,
                size: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }
}