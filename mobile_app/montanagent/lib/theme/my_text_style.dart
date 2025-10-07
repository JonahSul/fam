import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MyTextType {
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

class MyTextStyle {
  static Map<MyTextType, double> _defaultTextSize = {
    MyTextType.titleLarge: 22,
    MyTextType.titleMedium: 16,
    MyTextType.titleSmall: 14,
    MyTextType.bodyLarge: 16,
    MyTextType.bodyMedium: 14,
    MyTextType.bodySmall: 12,
    MyTextType.labelLarge: 14,
    MyTextType.labelMedium: 12,
    MyTextType.labelSmall: 11,
  };

  static Map<MyTextType, int> _defaultTextFontWeight = {
    MyTextType.titleLarge: 600,
    MyTextType.titleMedium: 600,
    MyTextType.titleSmall: 500,
    MyTextType.bodyLarge: 400,
    MyTextType.bodyMedium: 400,
    MyTextType.bodySmall: 400,
    MyTextType.labelLarge: 500,
    MyTextType.labelMedium: 500,
    MyTextType.labelSmall: 500,
  };

  static Map<MyTextType, double> _defaultLetterSpacing = {
    MyTextType.titleLarge: -0.5,
    MyTextType.titleMedium: 0.15,
    MyTextType.titleSmall: 0.1,
    MyTextType.bodyLarge: 0.5,
    MyTextType.bodyMedium: 0.25,
    MyTextType.bodySmall: 0.4,
    MyTextType.labelLarge: 0.1,
    MyTextType.labelMedium: 0.5,
    MyTextType.labelSmall: 0.5,
  };

  static TextStyle _getPoppinsStyle({TextStyle? textStyle, Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, double? wordSpacing, double? height, TextDecoration? decoration, Color? decorationColor}) => GoogleFonts.poppins(
    textStyle: textStyle,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    height: height,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  static void changeFontFamily(dynamic fontFamily) {
    // For now, we'll keep using Poppins as the default
    // This can be extended later if needed
  }

  static void changeDefaultFontWeight(Map<int, FontWeight> defaultFontWeight) {
    // Implementation for changing font weights
  }

  static void changeDefaultTextFontWeight(Map<MyTextType, int> defaultFontWeight) {
    _defaultTextFontWeight = defaultFontWeight;
  }

  static void changeDefaultTextSize(Map<MyTextType, double> defaultTextSize) {
    _defaultTextSize = defaultTextSize;
  }

  static void changeDefaultLetterSpacing(Map<MyTextType, double> defaultLetterSpacing) {
    _defaultLetterSpacing = defaultLetterSpacing;
  }

  static void resetFontStyles() {
    // Font family is now handled directly in _getPoppinsStyle
    _defaultTextSize = {
      MyTextType.titleLarge: 22,
      MyTextType.titleMedium: 16,
      MyTextType.titleSmall: 14,
      MyTextType.bodyLarge: 16,
      MyTextType.bodyMedium: 14,
      MyTextType.bodySmall: 12,
      MyTextType.labelLarge: 14,
      MyTextType.labelMedium: 12,
      MyTextType.labelSmall: 11,
    };
    _defaultTextFontWeight = {
      MyTextType.titleLarge: 600,
      MyTextType.titleMedium: 600,
      MyTextType.titleSmall: 500,
      MyTextType.bodyLarge: 400,
      MyTextType.bodyMedium: 400,
      MyTextType.bodySmall: 400,
      MyTextType.labelLarge: 500,
      MyTextType.labelMedium: 500,
      MyTextType.labelSmall: 500,
    };
    _defaultLetterSpacing = {
      MyTextType.titleLarge: -0.5,
      MyTextType.titleMedium: 0.15,
      MyTextType.titleSmall: 0.1,
      MyTextType.bodyLarge: 0.5,
      MyTextType.bodyMedium: 0.25,
      MyTextType.bodySmall: 0.4,
      MyTextType.labelLarge: 0.1,
      MyTextType.labelMedium: 0.5,
      MyTextType.labelSmall: 0.5,
    };
  }

  static TextStyle? getStyle(MyTextType textType, BuildContext context) {
    double fontSize = _defaultTextSize[textType]!;
    int fontWeight = _defaultTextFontWeight[textType]!;
    double letterSpacing = _defaultLetterSpacing[textType]!;

    switch (textType) {
      case MyTextType.titleLarge:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ).copyWith(height: 1.2);
      case MyTextType.titleMedium:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.titleMedium?.color,
        ).copyWith(height: 1.2);
      case MyTextType.titleSmall:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.titleSmall?.color,
        ).copyWith(height: 1.2);
      case MyTextType.bodyLarge:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ).copyWith(height: 1.4);
      case MyTextType.bodyMedium:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ).copyWith(height: 1.4);
      case MyTextType.bodySmall:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ).copyWith(height: 1.4);
      case MyTextType.labelLarge:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.labelLarge?.color,
        ).copyWith(height: 1.2);
      case MyTextType.labelMedium:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.labelMedium?.color,
        ).copyWith(height: 1.2);
      case MyTextType.labelSmall:
        return _getPoppinsStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeight ~/ 100],
          letterSpacing: letterSpacing,
          color: Theme.of(context).textTheme.labelSmall?.color,
        ).copyWith(height: 1.2);
    }
  }
}
