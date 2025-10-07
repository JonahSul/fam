import 'package:flutter/material.dart';

/// Custom gradient border implementation that doesn't cause layout issues
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({
    required this.gradient,
    this.width = 1.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  BorderSide get top => BorderSide(width: width);

  @override
  BorderSide get bottom => BorderSide(width: width);

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    if (shape == BoxShape.rectangle) {
      if (borderRadius != null) {
        final RRect rrect = RRect.fromRectAndCorners(
          rect,
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        );
        canvas.drawRRect(rrect, paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    } else {
      canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
    }
  }

  @override
  ShapeBorder scale(double t) => this;
}
