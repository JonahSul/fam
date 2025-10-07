import 'package:flutter/material.dart';
import 'my_text_style.dart';

class MyText extends StatelessWidget {
  final Key? key;
  final String text;
  final TextStyle? style;
  final int? fontWeight;
  final bool muted, xMuted;
  final double? letterSpacing;
  final Color? color;
  final TextDecoration decoration;
  final double? height;
  final double wordSpacing;
  final double? fontSize;
  final MyTextType textType;
  final TextAlign? textAlign;
  final int? maxLines;
  final Locale? locale;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  final bool? softWrap;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextHeightBehavior? textHeightBehavior;
  final double? textScaleFactor;
  final TextWidthBasis? textWidthBasis;

  MyText(this.text,
      {this.style,
      this.fontWeight = 500,
      this.muted = false,
      this.xMuted = false,
      this.letterSpacing = 0.15,
      this.color,
      this.decoration = TextDecoration.none,
      this.height,
      this.wordSpacing = 0,
      this.fontSize,
      this.textType = MyTextType.bodyMedium,
      this.key,
      this.textAlign,
      this.maxLines,
      this.locale,
      this.overflow,
      this.semanticsLabel,
      this.softWrap,
      this.strutStyle,
      this.textDirection,
      this.textHeightBehavior,
      this.textScaleFactor,
      this.textWidthBasis});

  @override
  Widget build(BuildContext context) {
    TextStyle? myStyle = style ?? MyTextStyle.getStyle(textType, context);

    if (fontSize != null) myStyle = myStyle?.copyWith(fontSize: fontSize);
    if (fontWeight != null) myStyle = myStyle?.copyWith(fontWeight: FontWeight.values[fontWeight! ~/ 100]);
    if (color != null) myStyle = myStyle?.copyWith(color: color);
    if (letterSpacing != null) myStyle = myStyle?.copyWith(letterSpacing: letterSpacing);
    if (height != null) myStyle = myStyle?.copyWith(height: height);
    if (decoration != null) myStyle = myStyle?.copyWith(decoration: decoration);
    if (wordSpacing != null) myStyle = myStyle?.copyWith(wordSpacing: wordSpacing);

    Color? finalColor = myStyle?.color;
    if (muted) {
      finalColor = myStyle?.color?.withAlpha(150);
    } else if (xMuted) {
      finalColor = myStyle?.color?.withAlpha(100);
    }

    if (finalColor != null) myStyle = myStyle?.copyWith(color: finalColor);

    return Text(
      text,
      style: myStyle,
      key: key,
      textAlign: textAlign,
      maxLines: maxLines,
      locale: locale,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }

  // Static helper methods
  static Widget titleLarge(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.titleLarge, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  static Widget titleMedium(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.titleMedium, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  static Widget titleSmall(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.titleSmall, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  static Widget bodyLarge(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.bodyLarge, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  static Widget bodyMedium(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.bodyMedium, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  static Widget bodySmall(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.bodySmall, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  static Widget labelLarge(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.labelLarge, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  static Widget labelMedium(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.labelMedium, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  static Widget labelSmall(String text, {TextStyle? style, Color? color, TextAlign? textAlign, int? maxLines}) {
    return MyText(text, textType: MyTextType.labelSmall, style: style, color: color, textAlign: textAlign, maxLines: maxLines);
  }
}
