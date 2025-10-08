import 'package:flutter/material.dart';
import 'my_screen_media_type.dart';

class MyResponsive extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints, MyScreenMediaType) builder;

  const MyResponsive({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenMT = _getScreenMediaType(constraints.maxWidth);
        return builder(context, constraints, screenMT);
      },
    );
  }

  MyScreenMediaType _getScreenMediaType(double width) {
    if (width < MyScreenMediaType.xs.width) {
      return MyScreenMediaType.xs;
    } else if (width < MyScreenMediaType.sm.width) {
      return MyScreenMediaType.sm;
    } else if (width < MyScreenMediaType.md.width) {
      return MyScreenMediaType.md;
    } else if (width < MyScreenMediaType.lg.width) {
      return MyScreenMediaType.lg;
    } else if (width < MyScreenMediaType.xl.width) {
      return MyScreenMediaType.xl;
    } else {
      return MyScreenMediaType.xxl;
    }
  }
}