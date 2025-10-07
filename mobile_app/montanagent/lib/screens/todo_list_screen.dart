import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_item.dart';
import '../services/session_service.dart';
import '../components/todo_item_widget.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ScrollController _scrollController = ScrollController();
  TodoStatus _selectedFilter = TodoStatus.pending;
  TodoPriority _selectedPriorityFilter = TodoPriority.medium;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My TODOs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox.shrink(),
                    Text('Generate TODOs from Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_completed',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox.shrink(),
                    Text('Clear Completed'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'generate') {
                _showGenerateTodosDialog(context);
              } else if (value == 'clear_completed') {
                _clearCompletedTodos(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox.shrink(),
                Wrap(
                  spacing: 8,
                  children: TodoStatus.values.map((status) {
                    return FilterChip(
                      label: Text(_getStatusDisplayName(status)),
                      selected: _selectedFilter == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = status;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox.shrink(),
                Text(
                  'Filter by Priority:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox.shrink(),
                Wrap(
                  spacing: 8,
                  children: TodoPriority.values.map((priority) {
                    return FilterChip(
                      label: Text(_getPriorityDisplayName(priority)),
                      selected: _selectedPriorityFilter == priority,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPriorityFilter = priority;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // TODO List
          Expanded(
              child: Consumer<SessionService>(
              builder: (context, sessionService, child) {
                final todos = sessionService.currentSessionTodos;
                final filteredTodos = todos.where((todo) {
                  final statusMatch = _selectedFilter == TodoStatus.pending 
                      ? todo.status != TodoStatus.completed && todo.status != TodoStatus.cancelled
                      : todo.status == _selectedFilter;
                  
                  final priorityMatch = _selectedPriorityFilter == TodoPriority.medium
                      ? true // Show all priorities when medium is selected
                      : todo.priority == _selectedPriorityFilter;
                  
                  return statusMatch && priorityMatch;
                }).toList();

                if (filteredTodos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox.shrink(),
                        Text(
                          todos.isEmpty 
                              ? 'No TODOs yet'
                              : 'No TODOs match your filters',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        SizedBox.shrink(),
                        Text(
                          todos.isEmpty
                              ? 'Start a conversation to generate TODOs!'
                              : 'Try adjusting your filters',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredTodos.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    return TodoItemWidget(
                      todo: todo,
                      onStatusChanged: (newStatus) async {
                        try {
                          final updatedTodo = todo.copyWith(
                            status: newStatus,
                            updatedAt: DateTime.now(),
                          );
                          await sessionService.updateTodo(updatedTodo);
                        } catch (e) {
                          _showErrorSnackBar('Failed to update TODO: $e');
                        }
                      },
                      onEdit: () => _showEditTodoDialog(context, todo),
                      onDelete: () => _showDeleteTodoDialog(context, todo),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateTodosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate TODOs from Chat'),
        content: const Text(
          'This will analyze your current chat conversation and generate relevant TODO items based on what you\'ve discussed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _generateTodosFromChat(context);
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateTodosFromChat(BuildContext context) async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    
    try {
      // Get messages from current session
      final messages = await sessionService.getCurrentSessionMessages().first;
      
      if (messages.isEmpty) {
        _showErrorSnackBar('No messages found in current session');
        return;
      }

      // Show loading indicator
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

      // Generate TODOs
      final todos = await sessionService.generateTodosFromConversation(messages);
      
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

  void _showAddTodoDialog(BuildContext context) {
    // TODO: Implement add TODO dialog
    _showInfoSnackBar('Add TODO feature coming soon!');
  }

  void _showEditTodoDialog(BuildContext context, TodoItem todo) {
    // TODO: Implement edit TODO dialog
    _showInfoSnackBar('Edit TODO feature coming soon!');
  }

  void _showDeleteTodoDialog(BuildContext context, TodoItem todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete TODO'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await Provider.of<SessionService>(context, listen: false)
                    .deleteTodo(todo.id);
                _showSuccessSnackBar('TODO deleted');
              } catch (e) {
                _showErrorSnackBar('Failed to delete TODO: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCompletedTodos(BuildContext context) async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    
    try {
      final completedTodos = sessionService.currentSessionTodos
          .where((todo) => todo.status == TodoStatus.completed)
          .toList();
      
      for (final todo in completedTodos) {
        await sessionService.deleteTodo(todo.id);
      }
      
      _showSuccessSnackBar('Cleared ${completedTodos.length} completed TODOs');
    } catch (e) {
      _showErrorSnackBar('Failed to clear completed TODOs: $e');
    }
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

  String _getStatusDisplayName(TodoStatus status) {
    switch (status) {
      case TodoStatus.pending:
        return 'Pending';
      case TodoStatus.inProgress:
        return 'In Progress';
      case TodoStatus.completed:
        return 'Completed';
      case TodoStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getPriorityDisplayName(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
      case TodoPriority.urgent:
        return 'Urgent';
    }
  }
}
