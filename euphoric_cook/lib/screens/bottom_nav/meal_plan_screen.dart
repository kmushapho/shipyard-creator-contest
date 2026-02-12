import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart'; // ← your AppColors file

class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  DateTime _selectedDate = DateTime.now();

  List<DateTime> getWeekDates() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  bool _isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getWeekDates();

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

              // ── Weekly Progress Card (inspo style) ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Weekly Progress',
                          style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            DateFormat('MMM yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              color: AppColors.lightText,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildProgressItem(
                          icon: Icons.directions_walk_rounded,
                          label: 'Steps',
                          value: '5,500',
                        ),
                        _buildProgressItem(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Done',
                          value: '12',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Horizontal Date Picker ───────────────────────────────────────────
              SizedBox(
                height: 96,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    final day = weekDates[index];
                    final isSelected = _isSelected(day);
                    final today = _isToday(day);

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDate = day);
                      },
                      child: Container(
                        width: 68,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.vibrantOrange
                              : (today ? AppColors.vibrantOrange.withOpacity(0.14) : AppColors.cardBgLight),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected || today
                              ? [
                            BoxShadow(
                              color: AppColors.vibrantOrange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
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
                                color: isSelected || today ? AppColors.lightText : AppColors.darkText.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected || today ? AppColors.lightText : AppColors.darkText,
                              ),
                            ),
                            if (today)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.vibrantOrange,
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

              // Selected day title
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Meal Cards ───────────────────────────────────────────────────────
              _buildMealCard(
                title: 'Breakfast',
                color: AppColors.vibrantGreen,
                items: const [
                  'Oats + Banana + 🥜',
                  'Greek Yogurt + Berries',
                ],
              ),

              const SizedBox(height: 16),

              _buildMealCard(
                title: 'Lunch',
                color: AppColors.vibrantBlue,
                items: const [
                  'Grilled Chicken Salad + Avocado',
                  'Quinoa + Roasted Veggies',
                ],
              ),

              const SizedBox(height: 16),

              _buildMealCard(
                title: 'Dinner',
                color: AppColors.vibrantOrange,
                items: const [
                  'Baked Salmon + Broccoli + Sweet Potato',
                  'Mixed Greens Salad',
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.lightText, size: 26),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.lightText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.lightText.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String title,
    required Color color,
    required List<String> items,
  }) {
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
              Icon(Icons.add_circle_outline_rounded, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 10, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.35,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}