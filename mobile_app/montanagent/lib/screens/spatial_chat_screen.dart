import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';
import '../services/session_service.dart';
import '../services/agent_mode_service.dart';
import '../components/agent/agent_avatar.dart';
import '../components/backgrounds/space_background.dart';
import '../services/firestore_service.dart';
import '../theme/index.dart';
import 'package:uuid/uuid.dart';

class SpatialChatScreen extends StatefulWidget {
  final Function(SpaceBackgroundState) onStateChange;

  const SpatialChatScreen({
    super.key,
    required this.onStateChange,
  });

  @override
  State<SpatialChatScreen> createState() => _SpatialChatScreenState();
}

class _SpatialChatScreenState extends State<SpatialChatScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isSendingMessage = false;
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

    // Initialize background state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBackgroundState();
    });

    // Initialize session and load messages
    _initializeSession();
  }

  void _updateBackgroundState() {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final agentMode = Provider.of<AgentModeService>(context, listen: false);

    widget.onStateChange(
      SpaceBackgroundState(
        currentPage: 'chat',
        isAgentMode: agentMode.isEnabled,
        interactionIntensity: _isSendingMessage ? 0.8 : 0.3,
        activeTodoCount: sessionService.currentSessionTodos.length,
        hasUnreadMessages: _messages.any((msg) => !msg.isUser && !_messages.any((m) => m.isUser && m.timestamp.isAfter(msg.timestamp))),
      ),
    );
  }

  void _loadSessionMessages() {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    sessionService.getCurrentSessionMessages().listen((messages) {
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
        _updateBackgroundState();
      }
    });
  }

  Future<void> _initializeSession() async {
    final sessionService = Provider.of<SessionService>(context, listen: false);

    // If no active session, start a new one
    if (!sessionService.hasActiveSession) {
      try {
        await sessionService.startNewSession();
      } catch (e) {
        debugPrint('Error starting new session: $e');
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating session: ${e.toString()}')),
          );
        }
      }
    }

    // Load messages for the current session
    _loadSessionMessages();
  }

  Future<void> _sendMessage() async {
    if (_isSendingMessage) return;

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      final chatService = Provider.of<ChatService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final sessionService = Provider.of<SessionService>(context, listen: false);

      // Ensure we have an active session
      if (!sessionService.hasActiveSession) {
        try {
          await _initializeSession();
          // Wait a bit for the session to be properly initialized
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating session: ${e.toString()}')),
          );
          return;
        }
      }

      setState(() {
        _isSendingMessage = true;
      });

      _updateBackgroundState();

      // Add user message immediately for better UX
      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        message: messageText,
        isUser: true,
        timestamp: DateTime.now(),
        chatSessionId: sessionService.currentSession!.id,
      );

      setState(() {
        _messages.add(userMessage);
      });

      _messageController.clear();

      // Save user message to Firestore
      await firestoreService.saveChatMessage(userMessage);

      // Get AI response
      String responseText;
      final agentMode = Provider.of<AgentModeService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      if (agentMode.isEnabled) {
        final agentResult = await agentMode.processMessageWithAgentMode(
          messages: _messages,
          chatSessionId: sessionService.currentSession!.id,
          userId: authService.user?.uid ?? 'anonymous',
          currentTodos: sessionService.currentSessionTodos,
        );
        responseText = agentResult.response.message.isNotEmpty
            ? agentResult.response.message
            : 'Okay.';
      } else {
        responseText = await chatService.sendMessage(messageText);
      }

      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        message: responseText,
        isUser: false,
        timestamp: DateTime.now(),
        chatSessionId: sessionService.currentSession!.id,
      );

      if (mounted) {
        setState(() {
          _messages.add(aiMessage);
        });
      }

      // Save AI message to Firestore
      await firestoreService.saveChatMessage(aiMessage);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
        _updateBackgroundState();
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              final floatOffset = Offset(
                math.sin(_floatAnimation.value * 2 * math.pi) * 2,
                math.cos(_floatAnimation.value * 2 * math.pi) * 1.5,
              );

              return Transform.translate(
                offset: floatOffset,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Container(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Chat messages area
                        Expanded(
                          child: _messages.isEmpty
                              ? _buildEmptyState()
                              : _buildMessagesList(),
                        ),

                        // Message input
                        Container(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          child: _buildMessageInput(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final sessionService = Provider.of<SessionService>(context);
    final bool hasSession = sessionService.hasActiveSession;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AgentAvatar(
            size: 120,
            useRive: true,
            isThinking: false,
            isExecuting: false,
          ),
          const SizedBox(height: 20),
          MyText.titleMedium(
            hasSession ? 'Hello! I\'m MontaNAgent.' : 'Welcome to MontaNAgent!',
            color: Colors.white.withOpacity(0.8),
          ),
          MySpacing.height(8),
          MyText.bodyLarge(
            hasSession
                ? 'How can I help you today?'
                : 'Start a conversation to begin your journey.',
            color: Colors.white.withOpacity(0.6),
          ),
          if (!hasSession) ...[
            MySpacing.height(16),
            MyButton.medium(
              onPressed: () async {
                try {
                  await _initializeSession();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: MyText.bodyMedium('Error creating session: ${e.toString()}')),
                    );
                  }
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: MyText.bodyMedium('Start Conversation', color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessage(_messages[index]);
      },
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            AgentAvatar(size: 32, useRive: true),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: MyCard(
              paddingAll: 12,
              color: message.isUser
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadiusAll: 18,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              child: MyText.bodyLarge(
                message.message,
                color: message.isUser ? Colors.white : Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return MyCard(
      color: Colors.white.withOpacity(0.1),
      borderRadiusAll: 25,
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      paddingAll: 12,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: MyTextStyle.getStyle(MyTextType.bodyMedium, context)?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: MyTextStyle.getStyle(MyTextType.bodyMedium, context)?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          MySpacing.width(8),
          MyButton.small(
            onPressed: _isSendingMessage ? null : _sendMessage,
            backgroundColor: Theme.of(context).primaryColor,
            child: _isSendingMessage
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.send, size: 16),
          ),
        ],
      ),
    );
  }
}
