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
    {"text": "Search By Pantry"},
    {"text": "Morning To Night"},
    {"text": "Healthy & Happy"},
    {"text": "Dicover New Flavors"},
    {"text": "Price & Prep"},

  ]
      : [
    {"text": "Alcoholic"},
    {"text": "Non-Alcoholic"},
    {"text": "Alcohol Optional"},
  ];
}