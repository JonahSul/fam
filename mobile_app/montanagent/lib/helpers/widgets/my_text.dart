import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const MyText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  static Widget titleLarge(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(
      text,
      style: style ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  static Widget titleMedium(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(
      text,
      style: style ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  static Widget bodyLarge(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(
      text,
      style: style ?? const TextStyle(fontSize: 16),
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  static Widget bodyMedium(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(
      text,
      style: style ?? const TextStyle(fontSize: 14),
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  static Widget bodySmall(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(
      text,
      style: style ?? const TextStyle(fontSize: 12),
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}