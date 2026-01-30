import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum AppMode { food, drink }

class ModeProvider extends ChangeNotifier {
  bool _isDark = false;
  AppMode _mode = AppMode.food;

  bool get isDark => _isDark;
  AppMode get currentMode => _mode;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  bool get isFood => _mode == AppMode.food;

  bool get isDrink => _mode == AppMode.drink;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void toggleFoodDrink() {
    _mode = _mode == AppMode.food ? AppMode.drink : AppMode.food;
    notifyListeners();
  }

  Color get accentColor => _mode == AppMode.food ? AppColors.vibrantOrange : AppColors.vibrantBlue;

  Color get textColor => _isDark ? AppColors.lightText : AppColors.darkText;

  Color get bgColor => _isDark ? AppColors.darkBg : AppColors.lightBg;

  Color get cardColor => _isDark ? AppColors.cardBgDark : AppColors.cardBgLight;

  TextStyle get featuredTitleStyle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  TextStyle get searchTextStyle => TextStyle(
    fontSize: 14,
    color: isDark ? Colors.white : Colors.black87,
  );

  TextStyle get searchHintStyle => TextStyle(
    fontSize: 14,
    color: isDark ? Colors.white : Colors.black87,
  );

  TextStyle get featuredTitleTextStyle => TextStyle(
    fontSize: 1,
    color: isDark ? Colors.white : Colors.black87,
  );


  String get searchHint => _mode == AppMode.food
      ? 'Search food recipes by name'
      : 'Search drink recipes by name';

  String get featuredTitle => _mode == AppMode.food ? 'Featured Recipes' : 'Featured Drinks';

  List<Map<String, String>> get categoryChips => _mode == AppMode.food
      ? [
    {'label': 'Search By Pantry'},
    {'label': 'All Day Meals'},
    {'label': 'Recently viewed'},
    {'label': 'Discover New Flavors'},
  ]
      : [
    {'label': 'Search By Pantry'},
    {'label': 'Alcoholic'},
    {'label': 'Non-Alcoholic'},
    {'label': 'Alcohol Optional'},
  ];
}