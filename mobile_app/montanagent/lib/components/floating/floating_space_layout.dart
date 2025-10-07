import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../glass/glass.dart';
import '../backgrounds/space_background.dart';
import '../hud/hud_overlay.dart';

/// Spatial layout system for floating glass tiles in virtual space
class FloatingSpaceLayout extends StatefulWidget {
  final SpaceBackgroundState backgroundState;
  final Widget Function(BuildContext context, int index) pageBuilder;
  final int pageCount;

  const FloatingSpaceLayout({
    super.key,
    required this.backgroundState,
    required this.pageBuilder,
    required this.pageCount,
  });

  @override
  State<FloatingSpaceLayout> createState() => _FloatingSpaceLayoutState();
}

class _FloatingSpaceLayoutState extends State<FloatingSpaceLayout>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  int _currentPage = 0;
  bool _isTransitioning = false;

  // Each page's position in virtual space
  final Map<int, Offset> _pagePositions = {};
  final Map<int, double> _pageScales = {};
  final Map<int, double> _pageRotations = {};

  // Procedural floating animation
  late List<AnimationController> _floatControllers;
  late List<Animation<double>> _floatAnimations;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Zoom animation for page transitions
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _zoomAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3, // Zoom out to 30% for transition
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOutCubic,
    ));

    // Global floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Initialize per-page floating animations
    _initializeFloatAnimations();

    // Generate initial page positions
    _generatePagePositions();
  }

  void _initializeFloatAnimations() {
    _floatControllers = [];
    _floatAnimations = [];

    for (int i = 0; i < widget.pageCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 3000 + i * 500), // Staggered timing
      )..repeat(reverse: true);

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      _floatControllers.add(controller);
      _floatAnimations.add(animation);
    }
  }

  void _generatePagePositions() {
    final random = math.Random(42); // Consistent seed

    for (int i = 0; i < widget.pageCount; i++) {
      // Create a spiral pattern in virtual space
      final angle = (i * 2 * math.pi) / widget.pageCount;
      final radius = 200.0 + i * 100.0; // Increasing distance

      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      _pagePositions[i] = Offset(x, y);
      _pageScales[i] = 0.8 + random.nextDouble() * 0.4; // 0.8 to 1.2 scale
      _pageRotations[i] = (random.nextDouble() - 0.5) * 0.3; // -0.15 to 0.15 radians
    }
  }

  void _animateToPage(int pageIndex) {
    if (_isTransitioning || pageIndex == _currentPage) return;

    setState(() {
      _isTransitioning = true;
    });

    // Zoom out animation
    _zoomController.forward().whenComplete(() {
      // Change page after zoom out
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ).whenComplete(() {
        // Zoom back in
        _zoomController.reverse().whenComplete(() {
          setState(() {
            _currentPage = pageIndex;
            _isTransitioning = false;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _zoomController.dispose();
    _floatController.dispose();

    for (final controller in _floatControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: RepaintBoundary(
            child: SimpleSpaceBackground(
              backgroundKey: GlobalKey(),
              state: widget.backgroundState,
              child: const SizedBox(),
            ),
          ),
        ),

        // Floating pages in virtual space
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _zoomAnimation,
              _floatAnimation,
              ..._floatAnimations,
            ]),
            builder: (context, child) {
              return Stack(
                children: List.generate(widget.pageCount, (index) {
                  final position = _pagePositions[index]!;
                  final scale = _pageScales[index]!;
                  final rotation = _pageRotations[index]!;

                  // Calculate distance-based effects
                  final distance = position.distance;
                  final normalizedDistance = (distance / 500.0).clamp(0.0, 1.0);

                  // Scale based on zoom state and distance
                  final currentScale = _isTransitioning
                      ? _zoomAnimation.value * scale * (1.0 - normalizedDistance * 0.5)
                      : scale * (1.0 - normalizedDistance * 0.3);

                  // Opacity based on distance
                  final opacity = (1.0 - normalizedDistance * 0.6).clamp(0.3, 1.0);

                  // Floating animation
                  final floatOffset = _calculateFloatOffset(index);

                  return Positioned(
                    left: MediaQuery.of(context).size.width / 2 + position.dx + floatOffset.dx - 150,
                    top: MediaQuery.of(context).size.height / 2 + position.dy + floatOffset.dy - 200,
                    child: Transform.scale(
                      scale: currentScale,
                      child: Transform.rotate(
                        angle: rotation + (_floatAnimations[index].value - 0.5) * 0.1,
                        child: Opacity(
                          opacity: opacity,
                          child: _FloatingGlassTile(
                            index: index,
                            currentPage: _currentPage,
                            backgroundState: widget.backgroundState,
                            child: widget.pageBuilder(context, index),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),

        // HUD overlay (on top of everything)
        Positioned.fill(
          child: HUDOverlay(
            backgroundState: widget.backgroundState,
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }

  Offset _calculateFloatOffset(int index) {
    final baseFloat = _floatAnimation.value;
    final perPageFloat = _floatAnimations[index].value;

    // Combine global and per-page floating
    final floatX = math.sin(baseFloat * 2 * math.pi + index * 0.5) * 3;
    final floatY = math.cos(perPageFloat * 2 * math.pi + index * 0.7) * 2;

    return Offset(floatX, floatY);
  }
}

class _FloatingGlassTile extends StatefulWidget {
  final int index;
  final int currentPage;
  final SpaceBackgroundState backgroundState;
  final Widget child;

  const _FloatingGlassTile({
    required this.index,
    required this.currentPage,
    required this.backgroundState,
    required this.child,
  });

  @override
  State<_FloatingGlassTile> createState() => _FloatingGlassTileState();
}

class _FloatingGlassTileState extends State<_FloatingGlassTile>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000 + widget.index * 300),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + widget.index * 200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.index == widget.currentPage;
    final glowIntensity = isActive ? 0.8 : 0.3;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(
                  glowIntensity * (0.3 + _glowAnimation.value * 0.4)
                ),
                blurRadius: 20 + _pulseAnimation.value * 5,
                spreadRadius: 2 + _glowAnimation.value * 3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GlassCard(
              backgroundKey: GlobalKey(),
              borderRadius: 20,
              padding: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05 + _pulseAnimation.value * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.cyan.withOpacity(
                      glowIntensity * (0.4 + _glowAnimation.value * 0.3)
                    ),
                    width: 1 + _pulseAnimation.value * 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
