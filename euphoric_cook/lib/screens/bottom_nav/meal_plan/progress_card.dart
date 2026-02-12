import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool showWeekly = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textColor = isDark ? AppColors.lightText : AppColors.darkText;
    final cardColor = isDark ? AppColors.cardBgDark : AppColors.cardBgLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Progress',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Toggle Daily / Weekly
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _toggleButton('Daily', !showWeekly),
                const SizedBox(width: 12),
                _toggleButton('Weekly', showWeekly),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  _buildStatCard('Calories', 1800, 2400, cardColor, textColor),
                  const SizedBox(height: 16),
                  _buildStatCard('Protein (g)', 120, 150, cardColor, textColor),
                  const SizedBox(height: 16),
                  _buildStatCard('Fats (g)', 60, 70, cardColor, textColor),
                  const SizedBox(height: 16),
                  _buildStatCard('Water (ml)', 1500, 2000, cardColor, textColor),
                  const SizedBox(height: 16),
                  _buildStatCard('Meals Logged', 4, 5, cardColor, textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => active ? null : active = !active),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.vibrantOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.vibrantOrange),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.vibrantOrange,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, int goal, Color bg, Color txt) {
    final fraction = (value / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: txt, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: fraction,
            minHeight: 12,
            backgroundColor: txt.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(AppColors.vibrantOrange),
          ),
          const SizedBox(height: 6),
          Text('$value / $goal', style: TextStyle(color: txt.withOpacity(0.75), fontSize: 13)),
        ],
      ),
    );
  }
}
