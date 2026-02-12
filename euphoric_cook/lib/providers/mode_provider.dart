import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum AppMode { food, drink }

class ModeProvider extends ChangeNotifier {
  bool _isDark = false;
  AppMode _mode = AppMode.food;


  bool get isDark => _isDark;
  bool get isLight => !_isDark;

  AppMode get currentMode => _mode;
  bool get isFood => _mode == AppMode.food;
  bool get isDrink => _mode == AppMode.drink;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Color get accentColor => isFood ? AppColors.vibrantOrange : Colors.orangeAccent;

  Color get textColor => _isDark ? AppColors.lightText : AppColors.darkText;

  Color get bgColor => _isDark ? AppColors.darkBg : AppColors.lightBg;

  Color get cardColor => _isDark ? AppColors.cardBgDark : AppColors.cardBgLight;
  Color get surfaceColor    => _isDark ? AppColors.cardBgDark : AppColors.cardBgLight;

  Color get textPrimary     => _isDark ? AppColors.lightText : AppColors.darkText;
  Color get textSecondary   => textPrimary.withOpacity(0.75);
  Color get textHint        => textPrimary.withOpacity(0.55);
  Color get textDisabled    => textPrimary.withOpacity(0.38);


  String get searchHint => _mode == AppMode.food
      ? 'Search food recipes by name'
      : 'Search drink recipes by name';


  TextStyle get bodyTextStyle => TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  TextStyle get titleMedium => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  TextStyle get titleLarge => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  TextStyle get searchTextStyle => TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  TextStyle get searchHintStyle => TextStyle(
    fontSize: 16,
    color: textHint,
  );


  String get searchHintText => isFood
      ? 'Search food recipes by name or ingredient'
      : 'Search drink recipes by name or ingredient';

  String get featuredSectionTitle => isFood ? 'Featured Recipes' : 'Featured Drinks';


  List<Map<String, String>> get categoryChips => isFood
      ? const [
    {'label': 'Search By Pantry'},
    {'label': 'All Day Meals'},
    {'label': 'Cuisines by region'},
    {'label': 'Recently viewed'},
  ]
      : const [
    {'label': 'Search By Pantry'},
    {'label': 'Alcoholic'},
    {'label': 'Non-Alcoholic'},
    {'label': 'Recently viewed'},
  ];

  // ── Actions ────────────────────────────────────────────────────────────────

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void toggleFoodDrink() {
    _mode = isFood ? AppMode.drink : AppMode.food;
    notifyListeners();
  }

  void setFoodMode() {
    if (!isFood) {
      _mode = AppMode.food;
      notifyListeners();
    }
  }

  void setDrinkMode() {
    if (!isDrink) {
      _mode = AppMode.drink;
      notifyListeners();
    }
  }

  // Optional: reset to defaults (useful for logout / onboarding)
  void reset() {
    _isDark = false;
    _mode = AppMode.food;
    notifyListeners();
  }
}