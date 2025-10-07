import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCustomizer {
  static ThemeCustomizer? _instance;
  static ThemeCustomizer get instance => _instance ??= ThemeCustomizer._();

  ThemeCustomizer._();

  ThemeMode _theme = ThemeMode.light;
  ThemeMode get theme => _theme;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme') ?? 'light';
    instance._theme = ThemeMode.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> changeTheme(ThemeMode theme) async {
    _theme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.name);
  }

  Future<void> toggleTheme() async {
    final newTheme = _theme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await changeTheme(newTheme);
  }
}
