import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _uid; // null = guest
  String _name;
  bool _isPremium;

  UserProvider._(this._uid, this._name, this._isPremium);

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

  bool get isGuest => _uid == null;
  bool get isLoggedIn => _uid != null;
  String get name => _name;
  bool get isPremium => _isPremium;

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
    notifyListeners();
  }
}
