import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mode_provider.dart';
import 'screens/home_screen.dart';
import '/constants/colors.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ModeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);

    return MaterialApp(
      title: 'Euphoric Cook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: AppColors.vibrantOrange,
        scaffoldBackgroundColor: mode.bgColor,
        colorScheme: ColorScheme.light(
          primary: AppColors.vibrantOrange,
          secondary: AppColors.vibrantGreen,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkText),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: AppColors.vibrantOrange,
        scaffoldBackgroundColor: mode.bgColor,
        colorScheme: ColorScheme.dark(
          primary: AppColors.vibrantOrange,
          secondary: AppColors.vibrantGreen,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.lightText),
        ),
      ),
      themeMode: mode.themeMode,
      home: const HomeScreen(),
    );
  }
}