import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final GestureTapCallback? onTap;
  final double? paddingAll;
  final double? borderRadiusAll;

  const MyCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.paddingAll,
    this.borderRadiusAll,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 
        (borderRadiusAll != null ? BorderRadius.circular(borderRadiusAll!) : BorderRadius.circular(8));
    final effectivePadding = padding ?? 
        (paddingAll != null ? EdgeInsets.all(paddingAll!) : const EdgeInsets.all(16));
    
    return Card(
      margin: margin,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}