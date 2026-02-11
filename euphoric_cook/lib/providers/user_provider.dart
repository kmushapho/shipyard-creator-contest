import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _uid; // null = guest
  String _name;
  bool _isPremium;

  // Selected tags (dietary, nutrition, allergy combined)
  final List<String> _selectedTags = [];

  // Foods to avoid (user input)
  final List<String> _foodsToAvoid = [];

  UserProvider._(this._uid, this._name, this._isPremium);

  // ───────────── FACTORIES ─────────────

  factory UserProvider.guest() {
    return UserProvider._(null, "Guest User", false);
  }

  factory UserProvider.loggedIn({
    required String uid,
    required String name,
    bool isPremium = false,
  }) {
    return UserProvider._(uid, name, isPremium);
  }

  // ───────────── GETTERS ─────────────

  bool get isGuest => _uid == null;
  bool get isLoggedIn => _uid != null;
  String get name => _name;
  bool get isPremium => _isPremium;

  List<String> get selectedTags => List.unmodifiable(_selectedTags);
  List<String> get foodsToAvoid => List.unmodifiable(_foodsToAvoid);

  // ───────────── AUTH ACTIONS ─────────────

  void login({
    required String uid,
    required String name,
    bool isPremium = false,
  }) {
    _uid = uid;
    _name = name;
    _isPremium = isPremium;
    notifyListeners();
  }

  void logoutToGuest() {
    _uid = null;
    _name = "Guest User";
    _isPremium = false;
    _selectedTags.clear();
    _foodsToAvoid.clear();
    notifyListeners();
  }

  // ───────────── TAGS (Dietary / Nutrition / Allergy) ─────────────

  bool isTagSelected(String tag) {
    return _selectedTags.contains(tag);
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearAllTags() {
    _selectedTags.clear();
    notifyListeners();
  }

  // ───────────── FOODS TO AVOID ─────────────

  void addFoodToAvoid(String food) {
    final trimmed = food.trim();
    if (trimmed.isEmpty) return;
    if (_foodsToAvoid.contains(trimmed)) return;

    _foodsToAvoid.add(trimmed);
    notifyListeners();
  }

  void removeFoodToAvoid(String food) {
    _foodsToAvoid.remove(food);
    notifyListeners();
  }

  void clearFoodsToAvoid() {
    _foodsToAvoid.clear();
    notifyListeners();
  }

  // ───────────── PREMIUM ─────────────

  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }
}
