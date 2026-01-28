import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mode_provider.dart';
import 'screens/home_screen.dart';

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
    final mode = context.watch<ModeProvider>();

    return MaterialApp(
      title: 'SpryCook',
      debugShowCheckedModeBanner: false,
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
      home: const HomeScreen(),
    );
  }
}