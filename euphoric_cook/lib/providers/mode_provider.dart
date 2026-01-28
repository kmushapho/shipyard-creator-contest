import 'package:flutter/material.dart';
import '/constants/colors.dart';

class ModeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  Color get accentColor => AppColors.vibrantOrange;

  Color get textColor => _isDark ? AppColors.lightText : AppColors.darkText;

  Color get bgColor => _isDark ? AppColors.darkBg : AppColors.lightBg;

  Color get cardColor => _isDark ? AppColors.cardBgDark : AppColors.cardBgLight;
}