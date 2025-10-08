import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class AppNotifier extends ChangeNotifier {
  AppNotifier();

  Future<void> init() async {
    _changeTheme();
    notifyListeners();
  }

  updateTheme() {
    _changeTheme();
    notifyListeners();
  }

  Future<void> updateInStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', ThemeMode.system.name);
    notifyListeners();
  }

  Future<void> changeLanguage() async {
    notifyListeners();
  }

  _changeTheme() {
    notifyListeners();
  }
}