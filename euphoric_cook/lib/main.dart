import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/mode_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load shared preferences early (before runApp)
  final prefs = await SharedPreferences.getInstance();

  // 2. Check if user has already completed onboarding
  //    Default to false → show onboarding on first launch
  final bool hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

  runApp(
    // 3. Provide ModeProvider at the top level (good practice)
    ChangeNotifierProvider(
      create: (_) => ModeProvider(),
      child: MyApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const MyApp({
    super.key,
    required this.hasCompletedOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    // Watch the provider (this rebuilds when theme/mode changes)
    final mode = context.watch<ModeProvider>();

    return MaterialApp(
      title: 'Euphoric Cook',
      debugShowCheckedModeBanner: false,

      // Theme setup — using your ModeProvider values
      themeMode: mode.themeMode,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: mode.accentColor),
        scaffoldBackgroundColor: mode.bgColor,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: mode.accentColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: mode.bgColor,
      ),

      // The key decision: onboarding only once
      home: hasCompletedOnboarding ? const HomeScreen() : const OnboardingScreen(),
    );

  }
}
