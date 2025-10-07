import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session_service.dart';
import '../../services/agent_mode_service.dart';
import '../backgrounds/space_background.dart';

/// Futuristic HUD overlay with glowing lines and translucent panels
class HUDOverlay extends StatefulWidget {
  final Widget child;
  final SpaceBackgroundState backgroundState;
  final VoidCallback? onHomePressed;
  final VoidCallback? onMissionsPressed;
  final VoidCallback? onCommsPressed;
  final VoidCallback? onArchivePressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onHelpPressed;
  final VoidCallback? onLogoutPressed;

  const HUDOverlay({
    super.key,
    required this.child,
    required this.backgroundState,
    this.onHomePressed,
    this.onMissionsPressed,
    this.onCommsPressed,
    this.onArchivePressed,
    this.onSettingsPressed,
    this.onProfilePressed,
    this.onHelpPressed,
    this.onLogoutPressed,
  });

  @override
  State<HUDOverlay> createState() => _HUDOverlayState();
}

class _HUDOverlayState extends State<HUDOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scanLineAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,

        // HUD overlay
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return _HUDLayer(
              backgroundState: widget.backgroundState,
              pulseAnimation: _pulseAnimation,
              scanLineAnimation: _scanLineAnimation,
            );
          },
        ),
      ],
    );
  }
}

class _HUDLayer extends StatelessWidget {
  final SpaceBackgroundState backgroundState;
  final Animation<double> pulseAnimation;
  final Animation<double> scanLineAnimation;
  final VoidCallback? onHomePressed;
  final VoidCallback? onMissionsPressed;
  final VoidCallback? onCommsPressed;
  final VoidCallback? onArchivePressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onHelpPressed;
  final VoidCallback? onLogoutPressed;

  const _HUDLayer({
    required this.backgroundState,
    required this.pulseAnimation,
    required this.scanLineAnimation,
    this.onHomePressed,
    this.onMissionsPressed,
    this.onCommsPressed,
    this.onArchivePressed,
    this.onSettingsPressed,
    this.onProfilePressed,
    this.onHelpPressed,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Top status bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 60,
          child: _TopStatusBar(
            backgroundState: backgroundState,
            pulseAnimation: pulseAnimation,
          ),
        ),

        // Left sidebar
        Positioned(
          left: 0,
          top: 60,
          bottom: 0,
          width: 80,
          child: _LeftSidebar(
            backgroundState: backgroundState,
            pulseAnimation: pulseAnimation,
            onHomePressed: onHomePressed,
            onMissionsPressed: onMissionsPressed,
            onCommsPressed: onCommsPressed,
            onArchivePressed: onArchivePressed,
          ),
        ),

        // Right sidebar
        Positioned(
          right: 0,
          top: 60,
          bottom: 0,
          width: 80,
          child: _RightSidebar(
            backgroundState: backgroundState,
            pulseAnimation: pulseAnimation,
          ),
        ),

        // Bottom control bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: _BottomControlBar(
            backgroundState: backgroundState,
            pulseAnimation: pulseAnimation,
          ),
        ),

        // Scanning line effect
        Positioned.fill(
          child: _ScanningLine(
            scanLineAnimation: scanLineAnimation,
          ),
        ),

        // Corner indicators
        Positioned(
          top: 20,
          left: 20,
          child: _CornerIndicator(
            type: 'top-left',
            pulseAnimation: pulseAnimation,
          ),
        ),

        Positioned(
          top: 20,
          right: 20,
          child: _CornerIndicator(
            type: 'top-right',
            pulseAnimation: pulseAnimation,
          ),
        ),

        Positioned(
          bottom: 20,
          left: 20,
          child: _CornerIndicator(
            type: 'bottom-left',
            pulseAnimation: pulseAnimation,
          ),
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: _CornerIndicator(
            type: 'bottom-right',
            pulseAnimation: pulseAnimation,
          ),
        ),
      ],
    );
  }
}

class _TopStatusBar extends StatelessWidget {
  final SpaceBackgroundState backgroundState;
  final Animation<double> pulseAnimation;

  const _TopStatusBar({
    required this.backgroundState,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.cyan.withOpacity(0.3 + pulseAnimation.value * 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _getPageTitle(backgroundState.currentPage),
              style: TextStyle(
                color: Colors.cyan.withOpacity(0.8 + pulseAnimation.value * 0.2),
                fontSize: 18,
                fontWeight: FontWeight.w300,
                shadows: [
                  Shadow(
                    color: Colors.cyan.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Status indicators
          Row(
            children: [
              _StatusIndicator(
                icon: Icons.smart_toy,
                active: backgroundState.isAgentMode,
                pulseAnimation: pulseAnimation,
              ),
              const SizedBox(width: 16),
              _StatusIndicator(
                icon: Icons.chat_bubble,
                active: backgroundState.hasUnreadMessages,
                pulseAnimation: pulseAnimation,
              ),
              const SizedBox(width: 16),
              _StatusIndicator(
                icon: Icons.task_alt,
                active: backgroundState.activeTodoCount > 0,
                pulseAnimation: pulseAnimation,
              ),
            ],
          ),

          const SizedBox(width: 20),
        ],
      ),
    );
  }

  String _getPageTitle(String page) {
    switch (page) {
      case 'chat': return 'NEURAL INTERFACE';
      case 'todos': return 'MISSION CONTROL';
      case 'meetings': return 'COMMUNICATIONS';
      case 'sessions': return 'ARCHIVE';
      default: return 'SYSTEM';
    }
  }
}

class _LeftSidebar extends StatelessWidget {
  final SpaceBackgroundState backgroundState;
  final Animation<double> pulseAnimation;
  final VoidCallback? onHomePressed;
  final VoidCallback? onMissionsPressed;
  final VoidCallback? onCommsPressed;
  final VoidCallback? onArchivePressed;

  const _LeftSidebar({
    required this.backgroundState,
    required this.pulseAnimation,
    this.onHomePressed,
    this.onMissionsPressed,
    this.onCommsPressed,
    this.onArchivePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        border: Border(
          right: BorderSide(
            color: Colors.cyan.withOpacity(0.2 + pulseAnimation.value * 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SidebarButton(
            icon: Icons.home,
            label: 'HOME',
            active: backgroundState.currentPage == 'chat',
            pulseAnimation: pulseAnimation,
            onPressed: onHomePressed,
          ),
          _SidebarButton(
            icon: Icons.task,
            label: 'MISSIONS',
            active: backgroundState.currentPage == 'todos',
            pulseAnimation: pulseAnimation,
            onPressed: onMissionsPressed,
          ),
          _SidebarButton(
            icon: Icons.group,
            label: 'COMMS',
            active: backgroundState.currentPage == 'meetings',
            pulseAnimation: pulseAnimation,
            onPressed: onCommsPressed,
          ),
          _SidebarButton(
            icon: Icons.history,
            label: 'ARCHIVE',
            active: backgroundState.currentPage == 'sessions',
            pulseAnimation: pulseAnimation,
            onPressed: onArchivePressed,
          ),
        ],
      ),
    );
  }
}

class _RightSidebar extends StatelessWidget {
  final SpaceBackgroundState backgroundState;
  final Animation<double> pulseAnimation;

  const _RightSidebar({
    required this.backgroundState,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        border: Border(
          left: BorderSide(
            color: Colors.cyan.withOpacity(0.2 + pulseAnimation.value * 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SidebarButton(
            icon: Icons.settings,
            label: 'SETTINGS',
            active: false,
            pulseAnimation: pulseAnimation,
          ),
          _SidebarButton(
            icon: Icons.person,
            label: 'PROFILE',
            active: false,
            pulseAnimation: pulseAnimation,
          ),
          _SidebarButton(
            icon: Icons.help,
            label: 'HELP',
            active: false,
            pulseAnimation: pulseAnimation,
          ),
          _SidebarButton(
            icon: Icons.power_settings_new,
            label: 'LOGOUT',
            active: false,
            pulseAnimation: pulseAnimation,
          ),
        ],
      ),
    );
  }
}

class _BottomControlBar extends StatelessWidget {
  final SpaceBackgroundState backgroundState;
  final Animation<double> pulseAnimation;

  const _BottomControlBar({
    required this.backgroundState,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.cyan.withOpacity(0.3 + pulseAnimation.value * 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.volume_up,
            label: 'AUDIO',
            pulseAnimation: pulseAnimation,
          ),
          _ControlButton(
            icon: Icons.brightness_6,
            label: 'DISPLAY',
            pulseAnimation: pulseAnimation,
          ),
          _ControlButton(
            icon: Icons.wifi,
            label: 'NETWORK',
            pulseAnimation: pulseAnimation,
          ),
          _ControlButton(
            icon: Icons.battery_full,
            label: 'POWER',
            pulseAnimation: pulseAnimation,
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Animation<double> pulseAnimation;
  final VoidCallback? onPressed;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.pulseAnimation,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? Colors.cyan.withOpacity(0.8 + pulseAnimation.value * 0.2)
                : Colors.cyan.withOpacity(0.3 + pulseAnimation.value * 0.1),
            width: active ? 2 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.3 + pulseAnimation.value * 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: active
                  ? Colors.cyan.withOpacity(0.9 + pulseAnimation.value * 0.1)
                  : Colors.cyan.withOpacity(0.5 + pulseAnimation.value * 0.1),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: active
                    ? Colors.cyan.withOpacity(0.9 + pulseAnimation.value * 0.1)
                    : Colors.cyan.withOpacity(0.5 + pulseAnimation.value * 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Animation<double> pulseAnimation;

  const _StatusIndicator({
    required this.icon,
    required this.active,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active
              ? Colors.greenAccent.withOpacity(0.8 + pulseAnimation.value * 0.2)
              : Colors.grey.withOpacity(0.3 + pulseAnimation.value * 0.1),
          width: 1,
        ),
        color: active
            ? Colors.greenAccent.withOpacity(0.1 + pulseAnimation.value * 0.1)
            : Colors.transparent,
      ),
      child: Icon(
        icon,
        size: 14,
        color: active
            ? Colors.greenAccent.withOpacity(0.9 + pulseAnimation.value * 0.1)
            : Colors.grey.withOpacity(0.5 + pulseAnimation.value * 0.1),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Animation<double> pulseAnimation;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.cyan.withOpacity(0.4 + pulseAnimation.value * 0.1),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.cyan.withOpacity(0.7 + pulseAnimation.value * 0.1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.cyan.withOpacity(0.6 + pulseAnimation.value * 0.1),
          ),
        ),
      ],
    );
  }
}

class _CornerIndicator extends StatelessWidget {
  final String type;
  final Animation<double> pulseAnimation;

  const _CornerIndicator({
    required this.type,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.cyan.withOpacity(0.4 + pulseAnimation.value * 0.2),
            width: 2,
          ),
          left: BorderSide(
            color: Colors.cyan.withOpacity(0.4 + pulseAnimation.value * 0.2),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _ScanningLine extends StatelessWidget {
  final Animation<double> scanLineAnimation;

  const _ScanningLine({
    required this.scanLineAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double position = (scanLineAnimation.value + 1) / 2; // Convert -1..1 to 0..1

        return Positioned(
          top: position * constraints.maxHeight,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.cyan.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
