import 'package:flutter/material.dart';

enum AppMode { food, drink }

class ModeProvider extends ChangeNotifier {
  AppMode current = AppMode.food;

  void switchMode() {
    if (current == AppMode.food) {
      current = AppMode.drink;
    } else {
      current = AppMode.food;
    }
    notifyListeners();
  }


  Color get mainColor => current == AppMode.food ? Colors.deepOrange : Colors.teal;

  Color get lightColor => current == AppMode.food ? Colors.orange.shade100 : Colors.teal.shade100;

  Color get backgroundColor => current == AppMode.food
      ? const Color(0xFFFFFBF5)
      : const Color(0xFFFAFEFF);

  String get searchPlaceholder => current == AppMode.food
      ? "Search food recipes by name"
      : "Search drink recipes by name";

  List<Map<String, dynamic>> get chipList => current == AppMode.food
      ? [
    {"text": "Search By Pantry", "icon": Icons.kitchen_sharp},
    {"text": "Morning To Night", "icon": Icons.wb_sunny_outlined},
    {"text": "Healthy & Happy", "icon": Icons.health_and_safety_outlined},
    {"text": "Dicover New Flavors", "icon": Icons.explore_off_outlined},
    {"text": "Price & Prep", "icon": Icons.price_change_outlined},

  ]
      : [
    {"text": "Alcoholic", "icon": Icons.wine_bar_outlined},
    {"text": "Non-Alcoholic", "icon": Icons.no_drinks_outlined},
    {"text": "Alcohol Optional", "icon": Icons.local_drink_outlined},
  ];
}