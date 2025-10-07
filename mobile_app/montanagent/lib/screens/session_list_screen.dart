import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_session.dart';
import '../services/session_service.dart';
import '../services/firestore_service.dart';
import '../components/glass/glass.dart';
import '../components/backgrounds/space_background.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleSpaceBackground(
        backgroundKey: _backgroundKey,
        state: SpaceBackgroundState(),
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewSession(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Chat Sessions'),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _startNewSession(context),
          tooltip: 'New Session',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<SessionService>(
      builder: (context, sessionService, child) {
        return StreamBuilder<List<ChatSession>>(
          stream: sessionService.getChatSessions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: GlassCard(
                  backgroundKey: _backgroundKey,
                  padding: EdgeInsets.zero,
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: GlassCard(
                  backgroundKey: _backgroundKey,
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox.shrink(),
                      Text(
                        'Error loading sessions',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox.shrink(),
                      Text(
                        snapshot.error.toString(),
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final sessions = snapshot.data ?? [];

            if (sessions.isEmpty) {
              return Center(
                child: GlassCard(
                  backgroundKey: _backgroundKey,
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withOpacity(0.7)),
                      SizedBox.shrink(),
                      Text(
                        'No chat sessions yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox.shrink(),
                      Text(
                        'Start a new conversation to begin',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      SizedBox.shrink(),
                      ElevatedButton.icon(
                        onPressed: () => _startNewSession(context),
                        icon: const Icon(Icons.add),
                        label: const Text('New Session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                return _buildSessionCard(context, sessions[index], sessionService);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    ChatSession session,
    SessionService sessionService,
  ) {
    final isCurrentSession = sessionService.currentSession?.id == session.id;

    return GlassCard(
      backgroundKey: _backgroundKey,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      color: isCurrentSession
          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
          : Colors.white.withOpacity(0.1),
      onTap: () => _resumeSession(context, session),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isCurrentSession ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isCurrentSession)
                Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                onPressed: () => _showSessionOptions(context, session),
              ),
            ],
          ),
          SizedBox.shrink(),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.white.withOpacity(0.7)),
              SizedBox.shrink(),
              Text(
                _formatDate(session.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              SizedBox.shrink(),
              Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white.withOpacity(0.7)),
              SizedBox.shrink(),
              Text(
                'Chat session',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Future<void> _startNewSession(BuildContext context) async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    
    try {
      await sessionService.startNewSession();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New session started')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start new session: $e')),
        );
      }
    }
  }

  Future<void> _resumeSession(BuildContext context, ChatSession session) async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    
    try {
      await sessionService.resumeSession(session.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resumed session: ${session.title}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resume session: $e')),
        );
      }
    }
  }

  void _showSessionOptions(BuildContext context, ChatSession session) {
    showModalBottomSheet(
      context: context,
      builder: (context) => GlassBottomSheet(
        backgroundKey: _backgroundKey,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Rename Session', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRenameDialog(context, session);
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Session', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteDialog(context, session);
                },
              ),
              SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, ChatSession session) {
    final controller = TextEditingController(text: session.title);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => GlassDialog(
        backgroundKey: _backgroundKey,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rename Session',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox.shrink(),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Session name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
              SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: () async {
                      final newTitle = controller.text.trim();
                      if (newTitle.isNotEmpty) {
                        final updatedSession = ChatSession(
                          id: session.id,
                          userId: session.userId,
                          title: newTitle,
                          createdAt: session.createdAt,
                          updatedAt: DateTime.now(),
                        );
                        await firestoreService.updateChatSession(updatedSession);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session renamed')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Rename'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChatSession session) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => GlassDialog(
        backgroundKey: _backgroundKey,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 48),
              SizedBox.shrink(),
              Text(
                'Delete Session?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox.shrink(),
              Text(
                'This will permanently delete "${session.title}" and all its messages.',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
              SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: () async {
                      await firestoreService.deleteChatSession(session.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session deleted')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}