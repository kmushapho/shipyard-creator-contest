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

  // Per-day data simulation
  final Map<String, int> _waterML = {};
  final Map<String, Set<String>> _completedMealItems = {};

  final int _waterGoalML = 2000;
  final int _maxMealsExample = 5;

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  DateTime get _effectiveDate => _selectedDate ?? DateTime.now();

  int get _todayWater => _waterML[_dateKey(_effectiveDate)] ?? 0;
  double get _waterFraction => (_todayWater / _waterGoalML).clamp(0.0, 1.0);

  int get _loggedCount {
    final key = _dateKey(_effectiveDate);
    return _completedMealItems[key]?.length ?? 0;
  }

  double get _mealsFraction => (_loggedCount / _maxMealsExample).clamp(0.0, 1.0);

  void _add250ml() {
    setState(() {
      final key = _dateKey(_effectiveDate);
      _waterML[key] = (_waterML[key] ?? 0) + 250;
    });
  }

  void _toggleItem(String uniqueKey) {
    setState(() {
      final key = _dateKey(_effectiveDate);
      _completedMealItems.putIfAbsent(key, () => {});
      if (_completedMealItems[key]!.contains(uniqueKey)) {
        _completedMealItems[key]!.remove(uniqueKey);
      } else {
        _completedMealItems[key]!.add(uniqueKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _effectiveDate.subtract(Duration(days: _effectiveDate.weekday - 1));
    final weekDates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

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
            children: [
              const SizedBox(height: 12),

              // ── Premium Progress Card (smaller & elegant) ─────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Daily Progress',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Water
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: _waterFraction,
                                    backgroundColor: Colors.blue.withOpacity(0.15),
                                    color: Colors.blue[400],
                                    strokeWidth: 8,
                                  ),
                                ),
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.blue[400],
                                  size: 36,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Water',
                              style: TextStyle(
                                color: Colors.blue[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _add250ml,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[400],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      '250 ml',
                                      style: TextStyle(color: Colors.white, fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Meals
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: _mealsFraction,
                                    backgroundColor: const Color(0xFF00E676).withOpacity(0.15),
                                    color: const Color(0xFF00E676),
                                    strokeWidth: 8,
                                  ),
                                ),
                                const Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF00E676),
                                  size: 36,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Meals',
                              style: TextStyle(
                                color: const Color(0xFF00E676),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$_loggedCount / $_maxMealsExample',
                              style: TextStyle(
                                color: AppColors.darkText.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Calendar ─────────────────────────────────────────────────────
              SizedBox(
                height: 96,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    final day = weekDates[index];
                    final isSelected = day.year == _effectiveDate.year &&
                        day.month == _effectiveDate.month &&
                        day.day == _effectiveDate.day;
                    final isToday = day.year == DateTime.now().year &&
                        day.month == DateTime.now().month &&
                        day.day == DateTime.now().day;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = day),
                      child: Container(
                        width: 68,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.vibrantOrange : AppColors.cardBgLight,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.vibrantOrange.withOpacity(0.3), blurRadius: 12)]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E().format(day).toUpperCase(),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.darkText.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.darkText,
                              ),
                            ),
                            if (isToday && !isSelected)
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

              const SizedBox(height: 24),

              // ── Date + Action Buttons Row ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      DateFormat('EEEE, MMMM d').format(_effectiveDate),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Create Meal Plan + Shopping List buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Open meal plan creator
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        'Create Meal Plan',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantOrange,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Open shopping list
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                      label: const Text(
                        'Shopping List',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.vibrantOrange,
                        side: BorderSide(color: AppColors.vibrantOrange),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Meal Cards (refined) ─────────────────────────────────────────
              _buildMealCard('Breakfast', AppColors.vibrantGreen),
              const SizedBox(height: 16),
              _buildMealCard('Lunch', AppColors.vibrantBlue),
              const SizedBox(height: 16),
              _buildMealCard('Dinner', AppColors.vibrantOrange),
              const SizedBox(height: 16),
              _buildMealCard('Snack', AppColors.vibrantGreen.withOpacity(0.85)),
              const SizedBox(height: 16),
              _buildMealCard('Dessert', AppColors.vibrantOrange.withOpacity(0.8)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBgLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.add_circle_outline_rounded, color: color, size: 28),
            ],
          ),
          // Placeholder space for future meal items
          const SizedBox(height: 16),
          Text(
            'Tap + to add meals',
            style: TextStyle(
              color: AppColors.darkText.withOpacity(0.45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}