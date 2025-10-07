import 'package:flutter/material.dart';

class ScreenMediaType {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const ScreenMediaType({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });
}

class MyResponsive extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, ScreenMediaType screenMediaType) builder;

  const MyResponsive({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        ScreenMediaType screenMediaType;

        if (width < 768) {
          screenMediaType = const ScreenMediaType(
            isMobile: true,
            isTablet: false,
            isDesktop: false,
          );
        } else if (width < 1200) {
          screenMediaType = const ScreenMediaType(
            isMobile: false,
            isTablet: true,
            isDesktop: false,
          );
        } else {
          screenMediaType = const ScreenMediaType(
            isMobile: false,
            isTablet: false,
            isDesktop: true,
          );
        }

        return builder(context, constraints, screenMediaType);
      },
    );
  }
}
