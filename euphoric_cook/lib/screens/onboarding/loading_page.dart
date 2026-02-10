import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../database_helper.dart';
import '../home_screen.dart';


class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _importData();
  }

  Future<void> _importData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.importCsvFromAssets('assets/recipes_w_search_terms.csv'); // Your CSV path
    // After import, go to home (you can add checks if already imported)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.vibrantOrange), // Simple animation
          const SizedBox(height: 20),
          const Text(
            'Loading Recipes...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}