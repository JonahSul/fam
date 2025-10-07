import 'package:flutter/material.dart';

class MyFlex extends StatelessWidget {
  final List<Widget> children;
  final bool contentPadding;

  const MyFlex({super.key, required this.children, this.contentPadding = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class MyFlexItem extends StatelessWidget {
  final Widget child;
  final String? sizes;

  const MyFlexItem({super.key, required this.child, this.sizes});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: child,
    );
  }
}
