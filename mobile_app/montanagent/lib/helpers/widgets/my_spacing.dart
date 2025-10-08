import 'package:flutter/material.dart';

class MySpacing {
  static EdgeInsets zero = EdgeInsets.zero;

  static EdgeInsets only({
    double top = 0,
    double right = 0,
    double bottom = 0,
    double left = 0,
  }) {
    return EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);
  }

  static EdgeInsets all(double spacing) {
    return MySpacing.only(
      bottom: spacing,
      top: spacing,
      right: spacing,
      left: spacing,
    );
  }

  static EdgeInsets horizontal(double spacing) {
    return MySpacing.only(left: spacing, right: spacing);
  }

  static EdgeInsets vertical(double spacing) {
    return MySpacing.only(top: spacing, bottom: spacing);
  }

  static EdgeInsets x(double spacing) {
    return MySpacing.only(left: spacing, right: spacing);
  }

  static EdgeInsets y(double spacing) {
    return MySpacing.only(top: spacing, bottom: spacing);
  }

  static EdgeInsets bottom(double spacing) {
    return MySpacing.only(bottom: spacing);
  }

  static EdgeInsets symmetric({double vertical = 0, double horizontal = 0}) {
    return MySpacing.only(
      top: vertical,
      right: horizontal,
      left: horizontal,
      bottom: vertical,
    );
  }

  static SizedBox height(double height) {
    return SizedBox(height: height);
  }

  static SizedBox width(double width) {
    return SizedBox(width: width);
  }

  static Widget empty() {
    return const SizedBox(width: 0, height: 0);
  }
}