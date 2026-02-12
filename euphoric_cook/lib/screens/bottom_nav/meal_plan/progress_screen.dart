import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors.dart';

class ProgressScreen extends StatefulWidget {
  final bool isDarkMode;
  const ProgressScreen({super.key, this.isDarkMode = false});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isDaily = true;
  DateTime _selectedDate = DateTime.now();

  // Simulated progress data
  int _waterML = 1250;
  int _waterGoal = 2000;

  int _calories = 1800;
  int _caloriesGoal = 2400;

  int _protein = 110;
  int _proteinGoal = 150;

  int _fats = 60;
  int _fatsGoal = 70;

  int _mealsLogged = 3;
  int _mealsGoal = 5;

  // Weekly data for graphs
  final List<int> _weeklyCalories = [2200, 2000, 1800, 1900, 2300, 2100, 1800];
  final List<int> _weeklyProtein = [120, 130, 110, 115, 125, 140, 110];
  final List<int> _weeklyFats = [60, 65, 55, 70, 68, 62, 57];
  final List<int> _weeklyWater = [1800, 1500, 1700, 2000, 1600, 1900, 1250];
  final List<int> _weeklyMeals = [5, 4, 3, 4, 5, 5, 3];

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? AppColors.darkBg : AppColors.lightBg;
    final cardColor = widget.isDarkMode ? AppColors.cardBgDark : AppColors.cardBgLight;
    final textColor = widget.isDarkMode ? AppColors.lightText : AppColors.darkText;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'My Progress',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildProgressCard(cardColor, textColor),
            const SizedBox(height: 20),
            _buildToggle(),
            const SizedBox(height: 16),
            _buildGraphCard("Calories", _isDaily ? [_calories] : _weeklyCalories, _caloriesGoal, AppColors.vibrantOrange, cardColor, textColor),
            const SizedBox(height: 16),
            _buildGraphCard("Protein (g)", _isDaily ? [_protein] : _weeklyProtein, _proteinGoal, AppColors.vibrantBlue, cardColor, textColor),
            const SizedBox(height: 16),
            _buildGraphCard("Fats (g)", _isDaily ? [_fats] : _weeklyFats, _fatsGoal, AppColors.vibrantGreen, cardColor, textColor),
            const SizedBox(height: 16),
            _buildGraphCard("Water (ml)", _isDaily ? [_waterML] : _weeklyWater, _waterGoal, Colors.blue, cardColor, textColor),
            const SizedBox(height: 16),
            _buildGraphCard("Meals Logged", _isDaily ? [_mealsLogged] : _weeklyMeals, _mealsGoal, AppColors.vibrantOrange, cardColor, textColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Color cardColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        // TODO: Expand for full details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tapped progress card for full details")),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Today\'s Progress',
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniProgress("Water", _waterML, _waterGoal, Icons.water_drop, Colors.blue),
                _buildMiniProgress("Meals", _mealsLogged, _mealsGoal, Icons.restaurant, AppColors.vibrantOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniProgress(String label, int value, int goal, IconData icon, Color color) {
    final fraction = (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: fraction,
                color: color,
                backgroundColor: color.withOpacity(0.2),
                strokeWidth: 7,
              ),
            ),
            Icon(icon, color: color, size: 30),
          ],
        ),
        const SizedBox(height: 8),
        Text("$value / $goal", style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.cardBgDark : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _toggleButton("Daily", _isDaily, () => setState(() => _isDaily = true)),
          _toggleButton("Weekly", !_isDaily, () => setState(() => _isDaily = false)),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.vibrantOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.darkText.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphCard(String title, List<int> values, int goal, Color color, Color cardColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                maxY: (values.reduce((a,b) => a>b?a:b) * 1.2).toDouble(),
                barGroups: List.generate(values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 6,
                    barRods: [
                      BarChartRodData(
                        toY: values[i].toDouble(),
                        color: color,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (_isDaily) return const Text('');
                        final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                        return Text(days[idx % 7], style: TextStyle(color: AppColors.darkText.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 12));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: goal/2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
