import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class AgentAvatar extends StatefulWidget {
  final bool isThinking;
  final bool isExecuting;
  final double size;
  final bool useRive;

  const AgentAvatar({super.key, this.isThinking = false, this.isExecuting = false, this.size = 40, this.useRive = false});

  @override
  State<AgentAvatar> createState() => _AgentAvatarState();
}

class _AgentAvatarState extends State<AgentAvatar> {
  rive.Artboard? _artboard;
  rive.StateMachineController? _controller;
  rive.SMIInput<bool>? _thinking;
  rive.SMIInput<bool>? _executing;

  @override
  void initState() {
    super.initState();
    if (widget.useRive) {
      _loadRive();
    }
  }

  Future<void> _loadRive() async {
    try {
      final file = await rive.RiveFile.asset('assets/agent/avatar.riv');
      final artboard = file.mainArtboard;
      final controller = rive.StateMachineController.fromArtboard(artboard, 'AgentState');
      if (controller != null) {
        artboard.addController(controller);
        _thinking = controller.findInput<bool>('thinking');
        _executing = controller.findInput<bool>('executing');
      }
      setState(() {
        _artboard = artboard;
      });
      _syncState();
    } catch (_) {
      // Silently fall back to static avatar
    }
  }

  @override
  void didUpdateWidget(covariant AgentAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.useRive && !oldWidget.useRive && _artboard == null) {
      _loadRive();
    }
    _syncState();
  }

  void _syncState() {
    _thinking?.value = widget.isThinking;
    _executing?.value = widget.isExecuting;
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: const Icon(Icons.psychology, color: Colors.white, size: 20),
    );

    if (_artboard == null) return avatar;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(child: rive.Rive(artboard: _artboard!)),
    );
  }
}


