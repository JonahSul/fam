import 'package:flutter/material.dart';

class MyTextStyle {
  static TextStyle bodyMedium({FontWeight? fontWeight, bool muted = false}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: muted ? Colors.grey[600] : null,
    );
  }

  static TextStyle bodySmall({FontWeight? fontWeight, bool muted = false, bool xMuted = false}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: xMuted ? Colors.grey[400] : (muted ? Colors.grey[600] : null),
    );
  }

  static TextStyle titleMedium({FontWeight? fontWeight, bool muted = false}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: muted ? Colors.grey[600] : null,
    );
  }

  static TextStyle titleSmall({FontWeight? fontWeight, bool muted = false, bool xMuted = false}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: xMuted ? Colors.grey[400] : (muted ? Colors.grey[600] : null),
    );
  }
}
