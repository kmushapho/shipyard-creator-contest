import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  // ───────────── USER INFO ─────────────
  String? _uid; // null = guest
  String _name;
  bool _isPremium;

  // ───────────── MEAL PLANNER RULES ─────────────
  final List<String> _selectedTags = [];
  final List<String> _foodsToAvoid = [];
  final List<String> _pantryItems = [];

  // ───────────── PREFERENCES ─────────────
  bool _isMetric = true;
  bool _isDarkMode = false;

  // ───────────── RECENTLY VIEWED ─────────────
  final List<String> _recentlyViewedFoods = [];
  final List<String> _recentlyViewedDrinks = [];
  static const int _recentlyViewedMax = 10;

  // ───────────── PRIVATE CONSTRUCTOR ─────────────
  UserProvider._(this._uid, this._name, this._isPremium);

  // ───────────── FACTORIES ─────────────
  factory UserProvider.guest() {
    return UserProvider._(null, "Guest User", false);
  }

  factory UserProvider.loggedIn({
    required String uid,
    required String name,
    bool isPremium = false,
    bool isDarkMode = false,
  }) {
    final provider = UserProvider._(uid, name, isPremium);
    provider._isDarkMode = isDarkMode;
    return provider;
  }

  // ───────────── GETTERS ─────────────
  bool get isGuest => _uid == null;
  bool get isLoggedIn => _uid != null;
  String get name => _name;
  bool get isPremium => _isPremium;

  List<String> get selectedTags => List.unmodifiable(_selectedTags);
  List<String> get foodsToAvoid => List.unmodifiable(_foodsToAvoid);
  List<String> get pantryItems => List.unmodifiable(_pantryItems);

  bool get isMetric => _isMetric;
  bool get isDarkMode => _isDarkMode;

  List<String> get recentlyViewedFoods => List.unmodifiable(_recentlyViewedFoods);
  List<String> get recentlyViewedDrinks => List.unmodifiable(_recentlyViewedDrinks);

  /// Get recently viewed depending on type
  List<String> getRecentlyViewed({required bool isFood}) {
    final list = isFood ? _recentlyViewedFoods : _recentlyViewedDrinks;
    if (list.isEmpty) return ['No recently viewed items'];
    return List.unmodifiable(list);
  }

  // ───────────── AUTH ACTIONS ─────────────
  void login({
    required String uid,
    required String name,
    bool isPremium = false,
    bool isDarkMode = false,
  }) {
    _uid = uid;
    _name = name;
    _isPremium = isPremium;
    _isDarkMode = isDarkMode;
    notifyListeners();
  }

  void logoutToGuest() {
    _uid = null;
    _name = "Guest User";
    _isPremium = false;
    _selectedTags.clear();
    _foodsToAvoid.clear();
    _pantryItems.clear();
    _recentlyViewedFoods.clear();
    _recentlyViewedDrinks.clear();
    _isMetric = true;
    _isDarkMode = false;
    notifyListeners();
  }

  // ───────────── TAGS ─────────────
  bool isTagSelected(String tag) => _selectedTags.contains(tag);

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
    if (trimmed.isEmpty || _foodsToAvoid.contains(trimmed)) return;
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

  // ───────────── PANTRY ITEMS ─────────────
  void addPantryItem(String food) {
    final trimmed = food.trim();
    if (trimmed.isEmpty || _pantryItems.contains(trimmed)) return;
    _pantryItems.add(trimmed);
    notifyListeners();
  }

  void removePantryItem(String food) {
    _pantryItems.remove(food);
    notifyListeners();
  }

  void clearPantry() {
    _pantryItems.clear();
    notifyListeners();
  }

  // ───────────── RECENTLY VIEWED ─────────────
  void addRecentlyViewed({required String item, required bool isFood}) {
    final list = isFood ? _recentlyViewedFoods : _recentlyViewedDrinks;
    list.remove(item); // remove if exists to move to front
    list.insert(0, item); // add at start
    if (list.length > _recentlyViewedMax) {
      list.removeLast(); // cap at 10
    }
    notifyListeners();
  }

  void clearRecentlyViewed({required bool isFood}) {
    if (isFood) {
      _recentlyViewedFoods.clear();
    } else {
      _recentlyViewedDrinks.clear();
    }
    notifyListeners();
  }

  // ───────────── PREFERENCES ─────────────
  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  void setMetric(bool value) {
    _isMetric = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // ───────────── OPTIONAL: CLEAR ALL MEAL PLANNER RULES ─────────────
  void clearMealPlannerRules() {
    _selectedTags.clear();
    _foodsToAvoid.clear();
    _pantryItems.clear();
    notifyListeners();
  }
}
