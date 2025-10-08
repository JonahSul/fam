import 'package:flutter/material.dart';

class MyFlexItem extends StatelessWidget {
  final Widget child;
  final String? sizes;

  const MyFlexItem({
    super.key,
    required this.child,
    this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(child: child);
  }
}

class MyFlex extends StatelessWidget {
  final List<MyFlexItem> children;
  final WrapAlignment wrapAlignment;
  final double spacing;
  final double runSpacing;

  const MyFlex({
    super.key,
    required this.children,
    this.wrapAlignment = WrapAlignment.start,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: wrapAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((item) => item.child).toList(),
    );
  }
}