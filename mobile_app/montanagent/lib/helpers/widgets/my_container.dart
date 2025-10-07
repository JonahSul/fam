import 'package:flutter/material.dart';

class MyContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;

  const MyContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.alignment,
    this.constraints,
  });

  const MyContainer.rounded({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.width,
    this.height,
    BorderRadius? borderRadius,
    this.border,
    this.boxShadow,
    this.alignment,
    this.constraints,
  }) : borderRadius = borderRadius ?? BorderRadius.circular(8);

  const MyContainer.transparent({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.alignment,
    this.constraints,
  }) : color = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
