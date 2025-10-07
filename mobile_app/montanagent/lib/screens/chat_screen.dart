import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquidglass_container/liquidglass_container.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';
import '../services/session_service.dart';
import '../routes/app_router.dart';
import '../components/theme_toggle_widget.dart';
import '../components/glass/glass.dart';
import '../components/backgrounds/space_background.dart';
import '../components/agent_mode_toggle.dart';
import '../components/agent/agent_avatar.dart';
import '../services/agent_mode_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final GlobalKey _backgroundKey = GlobalKey();
  bool _isSendingMessage = false;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  final List<_AgentSystemEvent> _agentEvents = [];

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure initialization happens after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    
    // If no active session, start a new one
    if (!sessionService.hasActiveSession) {
      try {
        await sessionService.startNewSession();
      } catch (e) {
        debugPrint('Error starting new session: $e');
      }
    }
    
    // Load messages for the current session
    _loadSessionMessages();
  }

  void _loadSessionMessages() {
    final sessionService = Provider.of<SessionService>(context, listen: false);

    // Cancel existing subscription to prevent memory leaks
    _messagesSubscription?.cancel();

    _messagesSubscription = sessionService.getCurrentSessionMessages().listen((messages) {
      if (mounted && messages.isNotEmpty) {
        // Use a more efficient update strategy for large message lists
        final shouldScrollToBottom = _messages.isEmpty ||
            _scrollController.hasClients &&
            _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100;

        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });

        // Only auto-scroll if we're at the bottom or this is the first load
        if (shouldScrollToBottom) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_isSendingMessage) return; // Prevent duplicate sends

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final chatService = Provider.of<ChatService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final sessionService = Provider.of<SessionService>(context, listen: false);

    if (!sessionService.hasActiveSession) {
      _showErrorSnackBar('No active session');
      return;
    }

    setState(() {
      _isSendingMessage = true;
    });

    try {
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

      // Auto-scroll to show the new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Save user message to Firestore
      await firestoreService.saveChatMessage(userMessage);

      // Get AI response, agentically if enabled
      String responseText;
      final agentMode = Provider.of<AgentModeService>(context, listen: false);
      if (agentMode.isEnabled) {
        final agentResult = await agentMode.processMessageWithAgentMode(
          messages: _messages,
          chatSessionId: sessionService.currentSession!.id,
          userId: Provider.of<AuthService>(context, listen: false).user?.uid ?? 'anonymous',
          currentTodos: sessionService.currentSessionTodos,
        );
        responseText = agentResult.response.message.isNotEmpty
            ? agentResult.response.message
            : 'Okay.';
      } else {
        responseText = await chatService.sendMessage(messageText).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('AI response timed out'),
        );
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

      // Auto-scroll to show AI response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Save AI message to Firestore
      await firestoreService.saveChatMessage(aiMessage);

      // Try to generate a TODO from the user's message
      try {
        await sessionService.generateTodoFromMessage(messageText);
      } catch (e) {
        debugPrint('Error generating TODO from message: $e');
      }

      // Agent mode: process tools if enabled
      try {
        final agentMode = Provider.of<AgentModeService>(context, listen: false);
        if (agentMode.isEnabled) {
          final startedAt = DateTime.now();
          setState(() {
            _agentEvents.insert(0, _AgentSystemEvent(
              summary: 'Agent: thinking…',
              inProgress: true,
              detailsBuilder: () => _AgentEventDetails.fromServiceSnapshot(agentMode),
            ));
          });
          await agentMode.processMessageWithAgentMode(
            messages: _messages,
            chatSessionId: sessionService.currentSession!.id,
            userId: Provider.of<AuthService>(context, listen: false).user?.uid ?? 'anonymous',
            currentTodos: sessionService.currentSessionTodos,
          );
          final endedAt = DateTime.now();
          final durationMs = endedAt.difference(startedAt).inMilliseconds;
          final took = (durationMs / 1000).toStringAsFixed(1);
          final execCount = agentMode.executionHistory.length;
          setState(() {
            // Update the most recent in-progress event
            final idx = _agentEvents.indexWhere((e) => e.inProgress);
            if (idx != -1) {
              _agentEvents[idx] = _AgentSystemEvent(
                summary: 'Agent: thought for ${took}s; ${execCount > 0 ? 'executed $execCount tool(s).' : 'no tool execution.'}',
                inProgress: false,
                detailsBuilder: () => _AgentEventDetails.fromServiceSnapshot(agentMode),
              );
            } else {
              _agentEvents.insert(0, _AgentSystemEvent(
                summary: 'Agent: thought for ${took}s; ${execCount > 0 ? 'executed $execCount tool(s).' : 'no tool execution.'}',
                inProgress: false,
                detailsBuilder: () => _AgentEventDetails.fromServiceSnapshot(agentMode),
              ));
            }
          });
        }
      } catch (e) {
        debugPrint('Agent mode processing failed: $e');
        setState(() {
          final idx = _agentEvents.indexWhere((ev) => ev.inProgress);
          final event = _AgentSystemEvent(
            summary: 'Agent: encountered an issue. Tap for details.',
            inProgress: false,
            detailsBuilder: () => _AgentEventDetails(error: e.toString()),
          );
          if (idx != -1) {
            _agentEvents[idx] = event;
          } else {
            _agentEvents.insert(0, event);
          }
        });
      }

    } catch (e) {
      if (mounted) {
        final errorMessage = ChatMessage(
          id: const Uuid().v4(),
          message: e is TimeoutException
              ? 'Request timed out. Please try again.'
              : 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
          chatSessionId: sessionService.currentSession!.id,
        );

        setState(() {
          _messages.add(errorMessage);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const AgentAvatar(size: 32, useRive: true),
            SizedBox.shrink(),
          ],
          Flexible(
            child: GlassCard(
              backgroundKey: _backgroundKey,
              borderRadius: 18,
              padding: EdgeInsets.zero,
              scrollController: _scrollController, // Scroll-responsive animated border
              color: message.isUser
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              child: Text(
                message.message,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox.shrink(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SimpleSpaceBackground(
        backgroundKey: _backgroundKey,
        state: SpaceBackgroundState(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            final horizontalPad = size.width * 0.05; // ~10% total
            final verticalPad = size.height * 0.02;   // ~4% total (reduced since AppBar is separate)
            return Padding(
              padding: EdgeInsets.zero,
              child: _buildBody(context),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
        title: Consumer<SessionService>(
          builder: (context, sessionService, child) {
            return Text(sessionService.currentSession?.title ?? 'MontaNAgent');
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Builder(builder: (context) {
            final agentMode = Provider.of<AgentModeService>(context);
            return Row(children: [
              AgentModeIndicator(
                agentModeService: agentMode,
                onTap: () => _showAgentModeStatus(context, agentMode),
              ),
              SizedBox.shrink(),
            ]);
          }),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showThemeSettings(context),
            tooltip: 'Theme Settings',
          ),
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.todos);
            },
            tooltip: 'View TODOs',
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.meetings);
            },
            tooltip: 'Find Meetings',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.sessions);
            },
            tooltip: 'Chat Sessions',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearChatDialog(context),
            tooltip: 'Clear Chat',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_session',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox.shrink(),
                    Text('New Session'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'generate_todos',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox.shrink(),
                    Text('Generate TODOs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'agent_mode',
                child: Row(
                  children: [
                    Icon(Icons.smart_toy),
                    SizedBox.shrink(),
                    Text('Agent Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox.shrink(),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'new_session':
                  await _startNewSession(context);
                  break;
                case 'generate_todos':
                  await _generateTodosFromChat(context);
                  break;
                case 'agent_mode':
                  final agentMode = Provider.of<AgentModeService>(context, listen: false);
                  _showAgentModeConfig(context, agentMode);
                  break;
                case 'logout':
                  final authService = Provider.of<AuthService>(context, listen: false);
                  await authService.signOut();
                  break;
              }
            },
          ),
        ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
        children: [
          // Messages List
          Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AgentAvatar(
                              size: 256,
                              useRive: true,
                              isThinking: false,
                              isExecuting: false,
                            ),
                            SizedBox.shrink(),
                            Text(
                              'Hello! I\'m MontaNAgent.',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            SizedBox.shrink(),
                            Text(
                              'How can I help you today?',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessage(_messages[index]);
                        },
                      ),
              ),

              // Loading Indicator
              Consumer<ChatService>(
                builder: (context, chatService, child) {
                  final agentMode = Provider.of<AgentModeService>(context);
                  if (chatService.isLoading || agentMode.isProcessing) {
                    return Container(
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          AgentAvatar(
                            size: 32,
                            useRive: true,
                            isThinking: chatService.isLoading,
                            isExecuting: agentMode.isProcessing,
                          ),
                          SizedBox.shrink(),
                          GlassCard(
                            backgroundKey: _backgroundKey,
                            borderRadius: 18,
                            padding: EdgeInsets.zero,
                            scrollController: _scrollController, // Scroll-responsive animated border
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 0,
                                  height: 0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox.shrink(),
                                Text(chatService.isLoading ? 'Thinking...' : 'Agent executing...'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Message Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          isCollapsed: true,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(
                          height: 1.0,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSendingMessage ? null : _sendMessage,
                      icon: _isSendingMessage
                          ? SizedBox(
                              width: 0,
                              height: 0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

          // Agent system messages (lightweight, non-bubble, tappable)
          if (_agentEvents.isNotEmpty)
            Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _agentEvents.take(3).map((event) {
                  return Padding(
                    padding: EdgeInsets.zero,
                    child: _AgentEventTile(
                      event: event,
                      onTap: () => _showAgentEventDetails(context, event),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
    );
  }

  Future<void> _startNewSession(BuildContext context) async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    
    try {
      await sessionService.startNewSession();
      setState(() {
        _messages.clear();
      });
      _loadSessionMessages();
      _showSuccessSnackBar('Started new session');
    } catch (e) {
      _showErrorSnackBar('Failed to start new session: $e');
    }
  }

  Future<void> _generateTodosFromChat(BuildContext context) async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    
    if (_messages.isEmpty) {
      _showInfoSnackBar('No messages to generate TODOs from');
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox.shrink(),
              Text('Generating TODOs...'),
            ],
          ),
        ),
      );

      final todos = await sessionService.generateTodosFromConversation(_messages);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (todos.isNotEmpty) {
        _showSuccessSnackBar('Generated ${todos.length} TODOs!');
      } else {
        _showInfoSnackBar('No TODOs were generated from this conversation');
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorSnackBar('Failed to generate TODOs: $e');
    }
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to clear the current chat? This will not delete the session or TODOs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _messages.clear();
              });
              _showInfoSnackBar('Chat cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showThemeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSettingsDialog(),
    );
  }

  void _showAgentModeStatus(BuildContext context, AgentModeService agentMode) {
    showDialog(
      context: context,
      builder: (context) => AgentModeStatusDialog(agentModeService: agentMode),
    );
  }

  void _showAgentModeConfig(BuildContext context, AgentModeService agentMode) {
    showDialog(
      context: context,
      builder: (context) => AgentModeConfigDialog(agentModeService: agentMode),
    );
  }

  void _showAgentEventDetails(BuildContext context, _AgentSystemEvent event) {
    final details = event.detailsBuilder();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agent Details'),
          content: SizedBox(
            width: 400,
            child: details.build(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _AgentSystemEvent {
  final String summary;
  final bool inProgress;
  final _AgentEventDetails Function() detailsBuilder;
  _AgentSystemEvent({required this.summary, this.inProgress = false, required this.detailsBuilder});
}

class _AgentEventDetails {
  final List<ToolExecution>? executions;
  final String? error;

  _AgentEventDetails({this.executions, this.error});

  factory _AgentEventDetails.fromServiceSnapshot(AgentModeService service) {
    return _AgentEventDetails(
      executions: service.executionHistory,
    );
  }

  Widget build(BuildContext context) {
    if (error != null) {
      return Text(
        error!,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final items = executions ?? const <ToolExecution>[];
    if (items.isEmpty) {
      return const Text('No tool executions.');
    }
    return SizedBox(
      height: 240,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final exec = items[index];
          return ListTile(
            dense: true,
            leading: Icon(
              exec.isCompleted
                  ? Icons.check_circle
                  : exec.isFailed
                      ? Icons.error
                      : Icons.more_horiz,
              color: exec.isCompleted
                  ? Colors.green
                  : exec.isFailed
                      ? Colors.red
                      : Colors.orange,
            ),
            title: Text(exec.toolName),
            subtitle: Text('Status: ${exec.status.name}\nTime: ${exec.timestamp.toLocal()}'),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}

class _AgentEventTile extends StatefulWidget {
  final _AgentSystemEvent event;
  final VoidCallback onTap;

  const _AgentEventTile({required this.event, required this.onTap});

  @override
  State<_AgentEventTile> createState() => _AgentEventTileState();
}

class _AgentEventTileState extends State<_AgentEventTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
    if (widget.event.inProgress) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AgentEventTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.event.inProgress && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.event.inProgress && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final baseColor = Colors.blueGrey.withOpacity(0.08);
          final ripple = widget.event.inProgress ? (0.04 * _pulse.value) : 0.0;
          return Container(
            decoration: BoxDecoration(
              color: Color.lerp(baseColor, Colors.black, ripple) ?? baseColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
            ),
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                SizedBox.shrink(),
                Expanded(
                  child: Text(
                    widget.event.summary,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (widget.event.inProgress) ...[
                  SizedBox.shrink(),
                  SizedBox(
                    width: 0,
                    height: 0,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                SizedBox.shrink(),
                const Icon(Icons.expand_more, size: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
