import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:liquidglass_container/liquidglass_container.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../services/render_quality_service.dart';

/// Base glass components using liquidglass_container
/// 
/// Use glass effects SELECTIVELY for:
/// - Cards (chat bubbles, content cards)
/// - Dialogs and modals
/// - Bottom sheets
/// - Main container panels
/// 
/// Use standard Material components for:
/// - Buttons (use Material buttons with styling)
/// - Text fields (use standard TextField)
/// - App bars (use standard AppBar)
/// - Small UI elements

/// Animated Gradient Border that responds to scroll
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final ScrollController? scrollController;
  final bool expandToFill;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.borderWidth = 1.5,
    this.scrollController,
    this.expandToFill = false,
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scrollVelocity = 0.0;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    // Animation duration will be set in build method based on quality settings
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController != null) {
      final position = widget.scrollController!.position;
      setState(() {
        _scrollPosition = position.pixels;
        _scrollVelocity = position.activity?.velocity ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get render quality settings
    final renderQualityService = Provider.of<RenderQualityService>(context);
    final animationParams = renderQualityService.getAnimationParams();

    // Update animation duration based on quality
    if (_controller.duration != animationParams.duration) {
      _controller.duration = animationParams.duration;
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }

    if (!animationParams.enabled) {
      // Return child without animation for low quality setting
      return widget.expandToFill
          ? SizedBox.expand(child: widget.child)
          : widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate gradient rotation based on scroll and animation
        final baseRotation = _controller.value * 2 * math.pi;
        final scrollInfluence = (_scrollVelocity.abs() / 1000.0).clamp(0.0, 1.0);
        final scrollOffset = (_scrollPosition / 100.0) % 1.0;
        final rotation = baseRotation + (scrollInfluence * math.pi / 2);

        // Dynamic gradient colors that respond to scroll velocity and quality settings
        final baseIntensity = animationParams.intensity;
        final intensity = baseIntensity + (scrollInfluence * (baseIntensity * 0.5));

        return CustomPaint(
          painter: _GradientBorderPainter(
            borderRadius: widget.borderRadius,
            borderWidth: widget.borderWidth,
            rotation: rotation,
            intensity: intensity,
            scrollOffset: scrollOffset,
          ),
          child: widget.expandToFill
              ? SizedBox.expand(child: child)
              : child,
        );
      },
      child: widget.child,
    );
  }
}

/// Custom painter for animated gradient border
class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final double rotation;
  final double intensity;
  final double scrollOffset;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.rotation,
    required this.intensity,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Inset the rect by half the border width so the outer edge of the stroke
    // aligns perfectly with the container's edge
    final halfBorderWidth = borderWidth / 2;
    final rect = Rect.fromLTRB(
      halfBorderWidth,
      halfBorderWidth,
      size.width - halfBorderWidth,
      size.height - halfBorderWidth,
    );
    
    // Adjust border radius to account for the inset
    // This ensures the border perfectly follows the container's rounded corners
    final adjustedRadius = math.max(0.0, borderRadius - halfBorderWidth);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(adjustedRadius),
    );

    // Create rotating gradient with scroll-responsive colors
    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: rotation,
      endAngle: rotation + 2 * math.pi,
      colors: [
        Colors.white.withOpacity(0.1 + intensity * 0.3),
        Colors.white.withOpacity(0.3 + intensity * 0.5),
        Colors.blue.withOpacity(0.2 + intensity * 0.4),
        Colors.purple.withOpacity(0.2 + intensity * 0.3),
        Colors.white.withOpacity(0.1 + intensity * 0.3),
      ],
      stops: [
        0.0,
        0.25 + scrollOffset * 0.1,
        0.5 + scrollOffset * 0.1,
        0.75 + scrollOffset * 0.1,
        1.0,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.intensity != intensity ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}

/// Glass Background - Wraps the entire screen to enable glass effects
class GlassBackground extends StatelessWidget {
  final Widget child;
  final GlobalKey backgroundKey;
  final Gradient? gradient;

  const GlassBackground({
    super.key,
    required this.child,
    required this.backgroundKey,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: backgroundKey,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: gradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
                ],
              ),
        ),
        child: child,
      ),
    );
  }
}

/// Glass Card - Beautiful card with liquid glass effect
/// USE THIS for: chat bubbles, content cards, feature cards
class GlassCard extends StatelessWidget {
  final Widget child;
  final GlobalKey backgroundKey;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final ScrollController? scrollController;
  final bool expandToFill;
  final bool showBorder;

  const GlassCard({
    super.key,
    required this.child,
    required this.backgroundKey,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.color,
    this.padding,
    this.margin,
    this.onTap,
    this.scrollController,
    this.expandToFill = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get render quality settings
    final renderQualityService = Provider.of<RenderQualityService>(context);
    final glassParams = renderQualityService.getGlassEffectParams();

    // Build the glass content with proper sizing
    Widget glassContent = LiquidGlassContainer(
      width: expandToFill ? double.infinity : width,
      height: expandToFill ? double.infinity : height,
      backgroundKey: backgroundKey,
      borderRadius: borderRadius,
      color: color ?? Colors.transparent,
      // Use quality-based shadow parameters
      shadowColor: Colors.white.withOpacity(glassParams.opacity),
      shadowBlurRadius: glassParams.shadowBlurRadius,
      shadowSpreadRadius: glassParams.shadowSpreadRadius,
      shadowOffset: glassParams.shadowOffset,
      // Use quality-based distortion parameters
      refraction: glassParams.refraction,
      chromaticDispersion: glassParams.chromaticDispersion,
      distortionStrength: glassParams.distortionStrength,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );

    // Wrap with animated border if enabled
    if (showBorder) {
      glassContent = AnimatedGradientBorder(
        borderRadius: borderRadius,
        scrollController: scrollController,
        expandToFill: expandToFill,
        child: glassContent,
      );
    }

    // Apply tap behavior if provided
    if (onTap != null) {
      glassContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: glassContent,
      );
    }

    // Apply margin and return
    return Container(
      margin: margin,
      width: expandToFill ? double.infinity : width,
      height: expandToFill ? double.infinity : height,
      child: glassContent,
    );
  }
}

/// Glass Container - Generic container with glass effect
/// USE THIS SPARINGLY for: special container panels, feature showcases
class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlobalKey backgroundKey;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final ScrollController? scrollController;
  final bool expandToFill;
  final bool showBorder;

  const GlassContainer({
    super.key,
    required this.child,
    required this.backgroundKey,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.color,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.alignment,
    this.scrollController,
    this.expandToFill = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get render quality settings
    final renderQualityService = Provider.of<RenderQualityService>(context);
    final glassParams = renderQualityService.getGlassEffectParams();

    // Build the glass content with proper sizing
    Widget glassContent = LiquidGlassContainer(
      width: expandToFill ? double.infinity : width,
      height: expandToFill ? double.infinity : height,
      backgroundKey: backgroundKey,
      borderRadius: borderRadius,
      color: color ?? Colors.transparent,
      // Use quality-based shadow parameters
      shadowColor: Colors.white.withOpacity(glassParams.opacity),
      shadowBlurRadius: glassParams.shadowBlurRadius,
      shadowSpreadRadius: glassParams.shadowSpreadRadius,
      shadowOffset: glassParams.shadowOffset,
      // Use quality-based distortion parameters
      refraction: glassParams.refraction,
      chromaticDispersion: glassParams.chromaticDispersion,
      distortionStrength: glassParams.distortionStrength,
      child: Container(
        padding: padding,
        alignment: alignment,
        child: child,
      ),
    );

    // Wrap with animated border if enabled
    if (showBorder) {
      glassContent = AnimatedGradientBorder(
        borderRadius: borderRadius,
        scrollController: scrollController,
        expandToFill: expandToFill,
        child: glassContent,
      );
    }

    // Apply margin and return
    return Container(
      margin: margin,
      width: expandToFill ? double.infinity : width,
      height: expandToFill ? double.infinity : height,
      child: glassContent,
    );
  }
}

/// Glass Dialog - Frosted machine-made glass for modals
/// Thinner, frostier appearance with more blur and less distortion
class GlassDialog extends StatelessWidget {
  final Widget child;
  final GlobalKey backgroundKey;
  final double borderRadius;
  final Color? color;
  final double? width;
  final double? height;
  final bool showBorder;

  const GlassDialog({
    super.key,
    required this.child,
    required this.backgroundKey,
    this.borderRadius = 24,
    this.color,
    this.width,
    this.height,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget dialogContent = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Frosted glass appearance - semi-opaque white
        color: const Color(0x18FFFFFF), // 10% white for frost
        borderRadius: BorderRadius.circular(borderRadius),
        // Soft shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // Backdrop blur for frosted effect
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              // Additional subtle tint
              color: color ?? const Color(0x08FFFFFF),
            ),
            child: child,
          ),
        ),
      ),
    );

    // Wrap with animated border if enabled
    if (showBorder) {
      dialogContent = AnimatedGradientBorder(
        borderRadius: borderRadius,
        borderWidth: 1.2,
        child: dialogContent,
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: dialogContent,
    );
  }
}

/// Glass Bottom Sheet - Frosted machine-made glass for sheets
/// Thinner, frostier appearance with more blur and less distortion
class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final GlobalKey backgroundKey;
  final double borderRadius;
  final Color? color;
  final ScrollController? scrollController;
  final bool showBorder;

  const GlassBottomSheet({
    super.key,
    required this.child,
    required this.backgroundKey,
    this.borderRadius = 24,
    this.color,
    this.scrollController,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget sheetContent = Container(
      decoration: BoxDecoration(
        // Frosted glass appearance - semi-opaque white
        color: const Color(0x11FFFFFF), // white frost TODO: should be translucent agent primary accent color variable
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        // Soft shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30.0,
            spreadRadius: 0.0,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      // Backdrop blur for frosted effect
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              // Additional subtle tint
              color: color ?? const Color(0x08FFFFFF), // translucent agent secondary accent color variable
            ),
            child: child,
          ),
        ),
      ),
    );

    // Wrap with animated border if enabled (top edge only for bottom sheet)
    if (showBorder) {
      sheetContent = AnimatedGradientBorder(
        borderRadius: borderRadius,
        borderWidth: 1.2,
        scrollController: scrollController,
        child: sheetContent,
      );
    }

    return sheetContent;
  }
}