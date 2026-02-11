import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/mode_provider.dart';
import 'providers/user_provider.dart';
import 'screens/bottom_nav/profile_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool hasCompletedOnboarding = false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider.guest()),
      ],
      child: MyApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const MyApp({super.key, required this.hasCompletedOnboarding});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: mode.themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: hasCompletedOnboarding
          ? const ProfileScreen()
          : const OnboardingScreen(),
    );
  }
}
