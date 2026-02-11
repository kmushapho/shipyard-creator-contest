// lib/providers/user_provider.dart
import 'package:flutter/material.dart';

/// Manages user profile data and preferences using Provider pattern.
/// All changes notify listeners to rebuild dependent UI.
class UserProvider with ChangeNotifier {
  // ────────────────────────────────────────────────
  // User data (hardcoded for demo – replace with real auth later)
  // ────────────────────────────────────────────────
  String _name = "Kgothatso";
  bool _isPremium = false;
  bool _notificationsEnabled = true;
  String _units = "Metric"; // "Metric" or "Imperial"

  List<String> _dietaryPreferences = [];
  List<String> _ingredientsToAvoid = [];

  // Getters
  String get name => _name;
  bool get isPremium => _isPremium;
  bool get notificationsEnabled => _notificationsEnabled;
  String get units => _units;
  List<String> get dietaryPreferences => _dietaryPreferences;
  List<String> get ingredientsToAvoid => _ingredientsToAvoid;

  // ────────────────────────────────────────────────
  // Actions / Mutators
  // ────────────────────────────────────────────────

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void setUnits(String value) {
    if (value == "Metric" || value == "Imperial") {
      _units = value;
      notifyListeners();
    }
  }

  void toggleDietaryPreference(String label) {
    if (_dietaryPreferences.contains(label)) {
      _dietaryPreferences.remove(label);
    } else {
      _dietaryPreferences.add(label);
    }
    notifyListeners();
  }

  void addIngredientToAvoid(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isNotEmpty && !_ingredientsToAvoid.contains(trimmed)) {
      _ingredientsToAvoid.add(trimmed);
      notifyListeners();
    }
  }

  void removeIngredientToAvoid(String ingredient) {
    _ingredientsToAvoid.remove(ingredient);
    notifyListeners();
  }

  // For demo / future login / subscription flow
  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // Optional: reset all preferences (e.g. on logout)
  void resetPreferences() {
    _dietaryPreferences = [];
    _ingredientsToAvoid = [];
    _notificationsEnabled = true;
    _units = "Metric";
    notifyListeners();
  }

  // Optional: full reset (useful during development or logout)
  void reset() {
    _name = "Guest";
    _isPremium = false;
    resetPreferences();
    notifyListeners();
  }
}