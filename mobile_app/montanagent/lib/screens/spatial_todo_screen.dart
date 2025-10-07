import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../components/backgrounds/space_background.dart';

class SpatialTodoScreen extends StatefulWidget {
  final Function(SpaceBackgroundState) onStateChange;

  const SpatialTodoScreen({
    super.key,
    required this.onStateChange,
  });

  @override
  State<SpatialTodoScreen> createState() => _SpatialTodoScreenState();
}

class _SpatialTodoScreenState extends State<SpatialTodoScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStateChange(
        const SpaceBackgroundState(
          currentPage: 'todos',
          isAgentMode: false,
          interactionIntensity: 0.2,
          activeTodoCount: 5,
          hasUnreadMessages: false,
        ),
      );
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        final floatOffset = Offset(
          math.sin(_floatAnimation.value * 2 * math.pi) * 2,
          math.cos(_floatAnimation.value * 2 * math.pi) * 1.5,
        );

        return Transform.translate(
          offset: floatOffset,
          child: Container(
            padding: EdgeInsets.zero,
            child: Center(
              child: Text(
                'TODO SCREEN\nComing Soon...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
