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
  final Map<String, Set<String>> _completedMealItems = {}; // e.g. "Breakfast-0", "Lunch-1" ...

  final int _waterGoalML = 2000;
  final int _maxMealsExample = 5; // for display only

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

  // Placeholder – would be called when user checks an item (once real items exist)
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

              // ── Progress Card ──────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.vibrantOrange.withOpacity(0.95), AppColors.vibrantOrange],
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
                  children: [
                    const Text(
                      'Your Current Progress',
                      style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Water – blue theme
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: _waterFraction,
                                    backgroundColor: Colors.white.withOpacity(0.25),
                                    color: Colors.blueAccent[400],
                                    strokeWidth: 10,
                                  ),
                                ),
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.blueAccent[400],
                                  size: 48,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Water',
                              style: TextStyle(
                                color: Colors.blueAccent[400],
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: _add250ml,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent[400],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.add, color: Colors.white, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      '250ml',
                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Meals – green theme
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: _mealsFraction,
                                    backgroundColor: Colors.white.withOpacity(0.25),
                                    color : Color(0xFF00E676),
                                    strokeWidth: 10,
                                  ),
                                ),
                                Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF00E676),
                                  size: 44,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Meals',
                                  style: TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_loggedCount / $_maxMealsExample logged',
                              style: TextStyle(
                                color: AppColors.lightText.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
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

              // Calendar (unchanged from previous version)
              SizedBox(
                height: 96,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    final day = weekDates[index];
                    final isSel = day.year == _effectiveDate.year &&
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
                          color: isSel ? AppColors.vibrantOrange : AppColors.cardBgLight,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSel
                              ? [BoxShadow(color: AppColors.vibrantOrange.withOpacity(0.35), blurRadius: 10)]
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
                                color: isSel ? AppColors.lightText : AppColors.darkText.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSel ? AppColors.lightText : AppColors.darkText,
                              ),
                            ),
                            if (isToday && !isSel)
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
                  DateFormat('EEEE, MMMM d').format(_effectiveDate),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
                ),
              ),

              const SizedBox(height: 16),

              // Meal cards – completely empty except title + add
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
          // Intentionally empty – no sample items, no checkboxes until real meals are added
        ],
      ),
    );
  }
}