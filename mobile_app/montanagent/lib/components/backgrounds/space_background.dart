import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

/// Background state that affects nebula colors and animations
class SpaceBackgroundState {
  final String currentPage; // 'chat', 'todos', 'meetings', 'sessions'
  final bool isAgentMode;
  final double interactionIntensity; // 0.0 to 1.0
  final int activeTodoCount;
  final bool hasUnreadMessages;

  const SpaceBackgroundState({
    this.currentPage = 'chat',
    this.isAgentMode = false,
    this.interactionIntensity = 0.0,
    this.activeTodoCount = 0,
    this.hasUnreadMessages = false,
  });

  SpaceBackgroundState copyWith({
    String? currentPage,
    bool? isAgentMode,
    double? interactionIntensity,
    int? activeTodoCount,
    bool? hasUnreadMessages,
  }) {
    return SpaceBackgroundState(
      currentPage: currentPage ?? this.currentPage,
      isAgentMode: isAgentMode ?? this.isAgentMode,
      interactionIntensity: interactionIntensity ?? this.interactionIntensity,
      activeTodoCount: activeTodoCount ?? this.activeTodoCount,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }
}

/// Interstellar space background - sparse, low-compute starfield
class SpaceBackground extends StatelessWidget {
  final GlobalKey backgroundKey;
  final Widget child;
  final SpaceBackgroundState state;

  const SpaceBackground({
    super.key,
    required this.backgroundKey,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background layer (captured by glass components)
        Positioned.fill(
          child: RepaintBoundary(
            key: backgroundKey,
            child: _StarfieldBackground(state: state),
          ),
        ),

        // Content layer (with glass effects)
        child,
      ],
    );
  }
}

/// Simpler space background that reuses the sparse starfield
class SimpleSpaceBackground extends StatelessWidget {
  final GlobalKey backgroundKey;
  final Widget child;
  final SpaceBackgroundState state;

  const SimpleSpaceBackground({
    super.key,
    required this.backgroundKey,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background layer (captured by glass components)
        Positioned.fill(
          child: RepaintBoundary(
            key: backgroundKey,
            child: _StarfieldBackground(state: state),
          ),
        ),

        // Content layer (with glass effects)
        child,
      ],
    );
  }
}

// Internal: lightweight starfield with sparse distribution and subtle twinkle
class _StarfieldBackground extends StatefulWidget {
  final SpaceBackgroundState state;

  const _StarfieldBackground({required this.state});

  @override
  State<_StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<_StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  SparseStarfieldGame? _game;
  late SpaceBackgroundState _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.state;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // slow, gentle twinkle
    )..repeat();
  }

  @override
  void didUpdateWidget(_StarfieldBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != _currentState) {
      _currentState = widget.state;
      // Trigger repaint with new state
      _game?.refreshWithState(_currentState);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final Size size = Size(constraints.maxWidth, constraints.maxHeight);
      _game ??= SparseStarfieldGame(size, _controller, _currentState);
      return GameWidget(game: _game!);
    });
  }
}

class _StarMeta {
  _StarMeta({
    required this.position,
    required this.radius,
    required this.baseOpacity,
    required this.b,
    required this.twinkle,
    required this.phase,
    required this.amp,
  });

  final Offset position;
  final double radius; // in logical pixels
  final double baseOpacity; // 0..1
  final double b; // slight blue tint factor 0..1
  final bool twinkle;
  final double phase; // 0..2pi
  final double amp; // 0..1 amplitude multiplier for twinkle
}

class _NebulaMeta {
  _NebulaMeta({
    required this.center,
    required this.width,
    required this.height,
    required this.rotation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.baseOpacity,
    required this.density,
    required this.turbulence,
    required this.animationPhase,
    required this.animationSpeed,
  });

  final Offset center;
  final double width;
  final double height;
  final double rotation; // radians
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final double baseOpacity; // 0..1
  final double density; // 0..1, controls internal detail
  final double turbulence; // 0..1, controls edge irregularity
  final double animationPhase; // 0..2pi
  final double animationSpeed; // multiplier for animation
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({
    required this.size,
    required this.timeListenable,
    required this.state,
  }) : super(repaint: timeListenable) {
    _generateStars();
    _generateNebulae();
  }

  final Size size;
  final Listenable timeListenable;
  SpaceBackgroundState state;
  final math.Random _rng = math.Random(1337); // stable seed for consistency
  final List<_StarMeta> _stars = <_StarMeta>[];
  final List<_NebulaMeta> _nebulae = <_NebulaMeta>[];

  void _generateStars() {
    _stars.clear();

    // Sparse: around 90-140 stars depending on area
    final double area = size.width * size.height;
    final int targetCount = (area / 18000).clamp(80, 140).toInt();

    for (int i = 0; i < targetCount; i++) {
      final double x = _rng.nextDouble() * size.width;
      final double y = _rng.nextDouble() * size.height;

      // Radius distribution: most tiny, few medium, rare larger
      final double rRoll = _rng.nextDouble();
      double radius;
      if (rRoll < 0.80) {
        radius = 0.6 + _rng.nextDouble() * 0.7; // 0.6 - 1.3
      } else if (rRoll < 0.97) {
        radius = 1.3 + _rng.nextDouble() * 0.9; // 1.3 - 2.2
      } else {
        radius = 2.2 + _rng.nextDouble() * 0.9; // 2.2 - 3.1 (rare)
      }

      // Slight color temperature variance: cool white bias
      final double blueBias = 0.85 + _rng.nextDouble() * 0.15; // 0.85-1.0
      final double opacity = 0.55 + _rng.nextDouble() * 0.4; // 0.55-0.95

      // Only a tiny fraction of the smallest stars twinkle
      final bool canTwinkle = radius < 1.2 && _rng.nextDouble() < 0.10; // ~10% of small
      final double phase = _rng.nextDouble() * math.pi * 2.0;
      final double amp = canTwinkle ? (0.08 + _rng.nextDouble() * 0.10) : 0.0; // very subtle

      _stars.add(
        _StarMeta(
          position: Offset(x, y),
          radius: radius,
          baseOpacity: opacity,
          b: blueBias,
          twinkle: canTwinkle,
          phase: phase,
          amp: amp,
        ),
      );
    }
  }

  void _generateNebulae() {
    _nebulae.clear();

    // Generate 6-8 nebulae with different characteristics - more for 120ppi detail
    final int nebulaCount = 6 + _rng.nextInt(3); // 6-8 nebulae

    for (int i = 0; i < nebulaCount; i++) {
      // Position nebulae across the screen, some extending beyond edges
      final double centerX = _rng.nextDouble() * size.width * 1.5 - size.width * 0.25;
      final double centerY = _rng.nextDouble() * size.height * 1.5 - size.height * 0.25;

      // Size varies significantly - optimized for 120ppi resolution
      final double sizeRoll = _rng.nextDouble();
      double width, height;
      if (sizeRoll < 0.3) {
        // Large background nebulae
        width = size.width * (0.8 + _rng.nextDouble() * 0.6); // 80-140% of screen width
        height = size.height * (0.6 + _rng.nextDouble() * 0.8); // 60-140% of screen height
      } else if (sizeRoll < 0.7) {
        // Medium nebulae
        width = size.width * (0.3 + _rng.nextDouble() * 0.5); // 30-80% of screen width
        height = size.height * (0.2 + _rng.nextDouble() * 0.6); // 20-80% of screen height
      } else {
        // Small detailed nebulae - finer for 120ppi
        width = size.width * (0.08 + _rng.nextDouble() * 0.25); // 8-33% of screen width
        height = size.height * (0.06 + _rng.nextDouble() * 0.2); // 6-26% of screen height
      }

      // Rotation for variety
      final double rotation = _rng.nextDouble() * math.pi * 2;

      // Color schemes based on application state
      Color primaryColor, secondaryColor, tertiaryColor;

      // Base colors influenced by current page
      switch (state.currentPage) {
        case 'chat':
          // Chat page - warm, conversational colors
          primaryColor = Color.fromARGB(255, 26, 26, 58); // Deep blue-purple
          secondaryColor = Color.fromARGB(255, 45, 27, 105); // Purple
          tertiaryColor = Color.fromARGB(255, 74, 44, 122); // Light purple
          break;
        case 'todos':
          // Todos page - organized, task-focused colors
          primaryColor = Color.fromARGB(255, 26, 58, 26); // Deep green
          secondaryColor = Color.fromARGB(255, 45, 105, 27); // Green
          tertiaryColor = Color.fromARGB(255, 74, 122, 44); // Light green
          break;
        case 'meetings':
          // Meetings page - warm, social colors
          primaryColor = Color.fromARGB(255, 58, 26, 26); // Deep red
          secondaryColor = Color.fromARGB(255, 105, 45, 27); // Red
          tertiaryColor = Color.fromARGB(255, 122, 74, 44); // Light red
          break;
        case 'sessions':
          // Sessions page - cool, reflective colors
          primaryColor = Color.fromARGB(255, 26, 42, 74); // Deep blue
          secondaryColor = Color.fromARGB(255, 45, 74, 122); // Blue
          tertiaryColor = Color.fromARGB(255, 74, 106, 155); // Light blue
          break;
        default:
          primaryColor = Color.fromARGB(255, 26, 26, 58); // Default blue-purple
          secondaryColor = Color.fromARGB(255, 45, 27, 105);
          tertiaryColor = Color.fromARGB(255, 74, 44, 122);
      }

      // Modify colors based on interaction intensity
      if (state.interactionIntensity > 0.5) {
        // High interaction - brighter, more vibrant colors
        primaryColor = primaryColor.withBlue((primaryColor.blue + 50).clamp(0, 255));
        secondaryColor = secondaryColor.withGreen((secondaryColor.green + 30).clamp(0, 255));
        tertiaryColor = tertiaryColor.withRed((tertiaryColor.red + 20).clamp(0, 255));
      } else if (state.interactionIntensity > 0.2) {
        // Medium interaction - slightly more vibrant
        primaryColor = primaryColor.withBlue((primaryColor.blue + 20).clamp(0, 255));
        secondaryColor = secondaryColor.withGreen((secondaryColor.green + 15).clamp(0, 255));
      }

      // Agent mode adds a subtle glow effect
      if (state.isAgentMode) {
        primaryColor = primaryColor.withOpacity(0.8);
        secondaryColor = secondaryColor.withOpacity(0.7);
        tertiaryColor = tertiaryColor.withOpacity(0.6);
      }

      // Opacity - extremely subtle for realism
      final double opacity = 0.005 + _rng.nextDouble() * 0.015; // 0.5-2% opacity

      // Density and turbulence for detail
      final double density = 0.3 + _rng.nextDouble() * 0.5; // 30-80% density
      final double turbulence = 0.2 + _rng.nextDouble() * 0.6; // 20-80% turbulence

      // Animation properties
      final double animationPhase = _rng.nextDouble() * math.pi * 2;
      final double animationSpeed = 0.05 + _rng.nextDouble() * 0.15; // Very slow, subtle movement

      _nebulae.add(
        _NebulaMeta(
          center: Offset(centerX, centerY),
          width: width,
          height: height,
          rotation: rotation,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          tertiaryColor: tertiaryColor,
          baseOpacity: opacity,
          density: density,
          turbulence: turbulence,
          animationPhase: animationPhase,
          animationSpeed: animationSpeed,
        ),
      );
    }
  }

  void refreshWithState(SpaceBackgroundState newState) {
    state = newState;
    _nebulae.clear();
    _generateNebulae();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Safety: fill background (already done by parent, but inexpensive)
    canvas.drawColor(const Color(0xFF000000), BlendMode.srcOver);

    // Use animation controller value for 60fps smooth animation
    final double t = (timeListenable as AnimationController).value * 8.0; // Scale to 8-second cycle

    // Render nebulae first (behind stars)
    _paintNebulae(canvas, size, t);

    // Render stars on top
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (final _StarMeta star in _stars) {
      double opacity = star.baseOpacity;
      if (star.twinkle) {
        // Gentle sinusoidal twinkle; amplitude is small for realism
        final double tw = 1.0 + star.amp * math.sin(t * 0.7 + star.phase);
        opacity = (opacity * tw).clamp(0.0, 1.0);
      }

      // Slight bluish white color
      final int value = (235 * star.b).clamp(210.0, 240.0).toInt();
      paint.color = Color.fromARGB((opacity * 255).toInt(), value, value, 255);
      canvas.drawCircle(star.position, star.radius, paint);
    }
  }

  void _paintNebulae(Canvas canvas, Size size, double time) {
    for (final _NebulaMeta nebula in _nebulae) {
      // Calculate animated properties - much slower and more subtle
      final double animationOffset = math.sin(time * nebula.animationSpeed + nebula.animationPhase) * 0.05;
      final double currentOpacity = nebula.baseOpacity * (0.9 + 0.1 * math.sin(time * 0.1 + nebula.animationPhase));

      // Create gradient for the nebula
      final Rect nebulaRect = Rect.fromCenter(
        center: Offset(
          nebula.center.dx + animationOffset * 20,
          nebula.center.dy + animationOffset * 15,
        ),
        width: nebula.width,
        height: nebula.height,
      );

      // Create radial gradient with multiple color stops
      final Gradient gradient = RadialGradient(
        center: const Alignment(0.0, 0.0),
        radius: 1.0,
        colors: [
          nebula.primaryColor.withOpacity(currentOpacity * 0.8),
          nebula.secondaryColor.withOpacity(currentOpacity * 0.6),
          nebula.tertiaryColor.withOpacity(currentOpacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      );

      // Create paint with gradient
      final Paint nebulaPaint = Paint()
        ..shader = gradient.createShader(nebulaRect)
        ..style = PaintingStyle.fill;

      // Save canvas state for rotation
      canvas.save();
      
      // Rotate around nebula center
      canvas.translate(nebula.center.dx, nebula.center.dy);
      canvas.rotate(nebula.rotation);
      canvas.translate(-nebula.center.dx, -nebula.center.dy);

      // Draw main nebula shape with turbulence
      _drawTurbulentEllipse(canvas, nebulaRect, nebulaPaint, nebula.turbulence, nebula.density);

      // Add subtle detail layers
      _addNebulaDetails(canvas, nebulaRect, nebula, currentOpacity, time);

      // Restore canvas state
      canvas.restore();
    }
  }

  void _drawTurbulentEllipse(Canvas canvas, Rect rect, Paint paint, double turbulence, double density) {
    final Path path = Path();
    final double centerX = rect.center.dx;
    final double centerY = rect.center.dy;
    final double radiusX = rect.width / 2;
    final double radiusY = rect.height / 2;

    // Create irregular ellipse with turbulence - optimized for 120ppi
    const int segments = 120; // Higher resolution for 120ppi smooth curves
    for (int i = 0; i <= segments; i++) {
      final double angle = (i / segments) * 2 * math.pi;
      final double baseRadiusX = radiusX * (0.7 + 0.3 * math.cos(angle * 2));
      final double baseRadiusY = radiusY * (0.8 + 0.2 * math.sin(angle * 3));
      
      // Add turbulence - finer detail for 120ppi
      final double turbulenceX = turbulence * 0.2 * math.sin(angle * 12 + _rng.nextDouble() * math.pi);
      final double turbulenceY = turbulence * 0.15 * math.cos(angle * 8 + _rng.nextDouble() * math.pi);
      
      final double currentRadiusX = baseRadiusX + turbulenceX * radiusX;
      final double currentRadiusY = baseRadiusY + turbulenceY * radiusY;
      
      final double x = centerX + currentRadiusX * math.cos(angle);
      final double y = centerY + currentRadiusY * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _addNebulaDetails(Canvas canvas, Rect rect, _NebulaMeta nebula, double opacity, double time) {
    // Add internal structure and wisps - optimized for 120ppi
    final int detailCount = (nebula.density * 12).round(); // More details for higher resolution
    
    for (int i = 0; i < detailCount; i++) {
      final double detailX = rect.left + _rng.nextDouble() * rect.width;
      final double detailY = rect.top + _rng.nextDouble() * rect.height;
      final double detailSize = (3 + _rng.nextDouble() * 8) * nebula.density; // Smaller, finer details for 120ppi
      
      // Animate detail movement - much slower
      final double detailAnimation = math.sin(time * 0.05 + i) * 0.2;
      final double animatedX = detailX + detailAnimation * 1;
      final double animatedY = detailY + detailAnimation * 0.5;
      
      // Create detail gradient
      final Gradient detailGradient = RadialGradient(
        center: const Alignment(0.0, 0.0),
        radius: 1.0,
        colors: [
          nebula.secondaryColor.withOpacity(opacity * 0.6),
          nebula.tertiaryColor.withOpacity(opacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      );
      
      final Paint detailPaint = Paint()
        ..shader = detailGradient.createShader(Rect.fromCircle(
          center: Offset(animatedX, animatedY),
          radius: detailSize,
        ))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(animatedX, animatedY), detailSize, detailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    // Repaint continuously but very light work: small circles only.
    return true;
  }
}

// Minimal Flame Game wrapper for painter to leverage GameWidget compositing
class SparseStarfieldGame extends Game {
  final Size logicalSize;
  final Listenable timeListenable;
  late final _StarfieldPainter _painter;
  SpaceBackgroundState _currentState;

  SparseStarfieldGame(this.logicalSize, this.timeListenable, this._currentState) {
    _painter = _StarfieldPainter(size: logicalSize, timeListenable: timeListenable, state: _currentState);
  }

  void refreshWithState(SpaceBackgroundState newState) {
    _currentState = newState;
    _painter.refreshWithState(newState);
  }

  @override
  void render(Canvas canvas) {
    _painter.paint(canvas, logicalSize);
  }

  @override
  void update(double dt) {}
}
