import 'package:flutter/material.dart';

enum MyButtonType { elevated, outlined, text }

class MyButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final MyButtonType? buttonType;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const MyButton({
    super.key,
    required this.child,
    this.onPressed,
    this.buttonType = MyButtonType.elevated,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    switch (buttonType) {
      case MyButtonType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          ),
          child: child,
        );
      case MyButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          ),
          child: child,
        );
      case MyButtonType.elevated:
      default:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          ),
          child: child,
        );
    }
  }

  static Widget medium(Widget child, {VoidCallback? onPressed, MyButtonType? buttonType}) {
    return MyButton(
      child: child,
      onPressed: onPressed,
      buttonType: buttonType,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static Widget large(Widget child, {VoidCallback? onPressed, MyButtonType? buttonType}) {
    return MyButton(
      child: child,
      onPressed: onPressed,
      buttonType: buttonType,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }
}