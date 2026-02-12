import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';

class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  DateTime? _selectedDate; // null = today

  // Per-day simulation (in real app → use database / provider)
  final Map<String, int> _waterIntakeML = {}; // key: "yyyy-MM-dd" → ml
  final Map<String, Set<String>> _loggedMeals = {}; // key: date → set of meal types logged

  final int _dailyWaterGoalML = 2000;

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  int get _currentWaterML {
    final key = _dateKey(effectiveDate);
    return _waterIntakeML[key] ?? 0;
  }

  int get _currentMealsLogged {
    final key = _dateKey(effectiveDate);
    return _loggedMeals[key]?.length ?? 0;
  }

  double get _waterProgress => _currentWaterML / _dailyWaterGoalML;
  double get _mealsProgress => _currentMealsLogged / 5.0; // assuming 5 possible: B,L,D,S,Des

  DateTime get effectiveDate => _selectedDate ?? DateTime.now();

  bool _isSelected(DateTime date) {
    return date.year == effectiveDate.year &&
        date.month == effectiveDate.month &&
        date.day == effectiveDate.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _addWater() {
    setState(() {
      final key = _dateKey(effectiveDate);
      _waterIntakeML[key] = (_waterIntakeML[key] ?? 0) + 250;
      if (_waterIntakeML[key]! > _dailyWaterGoalML * 2) {
        _waterIntakeML[key] = _dailyWaterGoalML * 2; // cap example
      }
    });
  }

  void _toggleMealLogged(String mealType) {
    setState(() {
      final key = _dateKey(effectiveDate);
      _loggedMeals.putIfAbsent(key, () => {});
      if (_loggedMeals[key]!.contains(mealType)) {
        _loggedMeals[key]!.remove(mealType);
      } else {
        _loggedMeals[key]!.add(mealType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = List.generate(
      7,
          (index) => DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index)),
    );

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        title: const Text(
          'Meal Planner',
          style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Progress Card ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.vibrantOrange.withOpacity(0.95), AppColors.vibrantOrange],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.vibrantOrange.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Current Progress',
                      style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Water column
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: _waterProgress.clamp(0.0, 1.0),
                                    backgroundColor: Colors.white.withOpacity(0.25),
                                    color: Colors.white,
                                    strokeWidth: 10,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(_currentWaterML / 1000).toStringAsFixed(1)}L',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '/2L',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _addWater,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 24),
                              ),
                            ),
                          ],
                        ),

                        // Meals logged circle
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: _mealsProgress.clamp(0.0, 1.0),
                                backgroundColor: Colors.white.withOpacity(0.25),
                                color: Colors.white,
                                strokeWidth: 12,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_currentMealsLogged',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'meals',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Check your progress so far',
                      style: TextStyle(
                        color: AppColors.lightText.withOpacity(0.85),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Calendar ────────────────────────────────────────────────────
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
                        });
                      },
                      child: Container(
                        width: 68,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.vibrantOrange : AppColors.cardBgLight,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: selected
                              ? [BoxShadow(color: AppColors.vibrantOrange.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
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
                                color: selected ? AppColors.lightText : AppColors.darkText.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: selected ? AppColors.lightText : AppColors.darkText,
                              ),
                            ),
                            if (today && !selected)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: AppColors.vibrantOrange.withOpacity(0.7), shape: BoxShape.circle),
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
                  DateFormat('EEEE, MMMM d').format(effectiveDate),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
                ),
              ),

              const SizedBox(height: 16),

              // ── Meal Cards ──────────────────────────────────────────────────
              _buildMealCard('Breakfast', AppColors.vibrantGreen),
              const SizedBox(height: 16),
              _buildMealCard('Lunch', AppColors.vibrantBlue),
              const SizedBox(height: 16),
              _buildMealCard('Dinner', AppColors.vibrantOrange),
              const SizedBox(height: 16),
              _buildMealCard('Snack', AppColors.vibrantGreen.withOpacity(0.8)),
              const SizedBox(height: 16),
              _buildMealCard('Dessert', AppColors.vibrantOrange.withOpacity(0.75)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(String title, Color color) {
    // For demo: let's pretend some days have items
    final bool hasItems = title == 'Breakfast' || title == 'Dinner'; // simulate
    final List<String> demoItems = hasItems ? ['Sample item 1', 'Sample item 2'] : [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBgLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
                child: Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              const Spacer(),
              Icon(Icons.add_circle_outline_rounded, color: color, size: 28),
            ],
          ),
          if (demoItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...demoItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLogged = _loggedMeals[_dateKey(effectiveDate)]?.contains('$title-$index') ?? false;

              return GestureDetector(
                onTap: () => _toggleMealLogged('$title-$index'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isLogged,
                        activeColor: color,
                        onChanged: (_) => _toggleMealLogged('$title-$index'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 15,
                            decoration: isLogged ? TextDecoration.lineThrough : null,
                            color: isLogged ? Colors.grey : AppColors.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}