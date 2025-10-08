import 'package:flutter/material.dart';

ThemeData get theme => AppTheme.theme;

class AppTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xffffffff),
      elevation: 2,
    ),
    scaffoldBackgroundColor: const Color(0xfff8f9fa),
  );

  static ThemeData getThemeFromThemeMode() {
    return theme;
  }
}