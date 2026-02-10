import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Our Features',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: [
                _featureCard(Icons.search, 'Search Pantry'),
                _featureCard(Icons.book, 'Build Cookbook'),
                _featureCard(Icons.share, 'Share Recipes'),
                _featureCard(Icons.calendar_today, 'Meal Planner'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String label) {
    return Card(
      color: AppColors.vibrantOrange.withOpacity(0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.vibrantOrange),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}