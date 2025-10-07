import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/todo_item.dart';
import 'firestore_service.dart';

/// AI-powered service for generating TODOs from chat conversations
class TodoAIService extends ChangeNotifier {
  final FirestoreService _firestoreService;
  bool _isGenerating = false;

  TodoAIService(this._firestoreService);

  bool get isGenerating => _isGenerating;

  /// Generate TODOs from a chat conversation
  Future<List<TodoItem>> generateTodosFromChat({
    required String chatSessionId,
    required List<ChatMessage> messages,
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // Prepare conversation context for AI analysis
      final conversationText = _prepareConversationForAI(messages);
      
      // Call the GenKit service to analyze the conversation
      final todos = await _analyzeConversationWithAI(conversationText, chatSessionId);
      
      // Save TODOs to Firestore
      final savedTodos = <TodoItem>[];
      for (final todo in todos) {
        try {
          final savedTodo = await _firestoreService.createTodoItem(
            title: todo.title,
            description: todo.description,
            priority: todo.priority,
            chatSessionId: chatSessionId,
            aiContext: todo.aiContext,
            tags: todo.tags,
            dueDate: todo.dueDate,
          );
          savedTodos.add(savedTodo);
        } catch (e) {
          debugPrint('Error saving TODO: $e');
        }
      }

      return savedTodos;
    } catch (e) {
      debugPrint('Error generating TODOs: $e');
      rethrow;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Prepare conversation text for AI analysis
  String _prepareConversationForAI(List<ChatMessage> messages) {
    final buffer = StringBuffer();
    
    for (final message in messages) {
      final sender = message.isUser ? 'User' : 'MontaNAgent';
      buffer.writeln('$sender: ${message.message}');
    }
    
    return buffer.toString();
  }

  /// Analyze conversation with AI to generate TODOs
  Future<List<TodoItem>> _analyzeConversationWithAI(
    String conversation,
    String chatSessionId,
  ) async {
    try {
      const baseUrl = 'http://localhost:3000';
      
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-todos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'conversation': conversation,
          'chatSessionId': chatSessionId,
          'context': 'recovery_support',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('AI analysis timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseTodosFromAIResponse(data);
      } else {
        throw Exception('AI analysis failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error analyzing conversation with AI: $e');
      // Fallback: generate basic TODOs based on conversation keywords
      return _generateFallbackTodos(conversation, chatSessionId);
    }
  }

  /// Parse TODOs from AI response
  List<TodoItem> _parseTodosFromAIResponse(Map<String, dynamic> data) {
    final todos = <TodoItem>[];
    final todosData = data['todos'] as List<dynamic>? ?? [];

    for (final todoData in todosData) {
      try {
        final todo = TodoItem(
          id: '', // Will be set when saved
          title: todoData['title'] ?? 'Untitled Task',
          description: todoData['description'] ?? '',
          priority: _parsePriority(todoData['priority']),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          chatSessionId: todoData['chatSessionId'],
          aiContext: todoData['aiContext'],
          tags: List<String>.from(todoData['tags'] ?? []),
          dueDate: todoData['dueDate'] != null 
              ? DateTime.tryParse(todoData['dueDate']) 
              : null,
        );
        todos.add(todo);
      } catch (e) {
        debugPrint('Error parsing TODO: $e');
      }
    }

    return todos;
  }

  /// Parse priority from string
  TodoPriority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return TodoPriority.urgent;
      case 'high':
        return TodoPriority.high;
      case 'low':
        return TodoPriority.low;
      default:
        return TodoPriority.medium;
    }
  }

  /// Generate fallback TODOs when AI analysis fails
  List<TodoItem> _generateFallbackTodos(String conversation, String chatSessionId) {
    final todos = <TodoItem>[];
    final lowerConversation = conversation.toLowerCase();

    // Recovery-related keywords and their corresponding TODOs
    final recoveryKeywords = {
      'meeting': {
        'title': 'Find NA Meeting',
        'description': 'Look for Narcotics Anonymous meetings in your area',
        'priority': TodoPriority.high,
        'tags': ['recovery', 'meetings'],
      },
      'sponsor': {
        'title': 'Find a Sponsor',
        'description': 'Connect with someone who can guide you through the 12 steps',
        'priority': TodoPriority.high,
        'tags': ['recovery', 'sponsor'],
      },
      'step': {
        'title': 'Work on 12 Steps',
        'description': 'Continue working through the 12 steps of recovery',
        'priority': TodoPriority.medium,
        'tags': ['recovery', 'steps'],
      },
      'therapy': {
        'title': 'Schedule Therapy Session',
        'description': 'Book an appointment with a therapist or counselor',
        'priority': TodoPriority.medium,
        'tags': ['therapy', 'mental-health'],
      },
      'exercise': {
        'title': 'Physical Activity',
        'description': 'Engage in physical exercise to support your recovery',
        'priority': TodoPriority.medium,
        'tags': ['health', 'exercise'],
      },
      'meditation': {
        'title': 'Practice Meditation',
        'description': 'Spend time in meditation or mindfulness practice',
        'priority': TodoPriority.low,
        'tags': ['mindfulness', 'meditation'],
      },
    };

    for (final entry in recoveryKeywords.entries) {
      if (lowerConversation.contains(entry.key)) {
        final todoData = entry.value;
        final todo = TodoItem(
          id: '',
          title: todoData['title'] as String,
          description: todoData['description'] as String,
          priority: todoData['priority'] as TodoPriority,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          chatSessionId: chatSessionId,
          aiContext: 'Generated based on conversation keywords',
          tags: List<String>.from(todoData['tags'] as List),
        );
        todos.add(todo);
      }
    }

    // If no specific keywords found, create a general recovery TODO
    if (todos.isEmpty) {
      final generalTodo = TodoItem(
        id: '',
        title: 'Continue Recovery Journey',
        description: 'Keep working on your recovery goals and stay connected with your support network',
        priority: TodoPriority.medium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        chatSessionId: chatSessionId,
        aiContext: 'General recovery support TODO',
        tags: ['recovery', 'general'],
      );
      todos.add(generalTodo);
    }

    return todos;
  }

  /// Generate a single TODO from a specific message
  Future<TodoItem?> generateTodoFromMessage({
    required String message,
    required String chatSessionId,
  }) async {
    try {
      const baseUrl = 'http://localhost:3000';
      
      final response = await http.post(
        Uri.parse('$baseUrl/generate-single-todo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'message': message,
          'chatSessionId': chatSessionId,
          'context': 'recovery_support',
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('TODO generation timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final todoData = data['todo'];
        
        if (todoData != null) {
          return TodoItem(
            id: '',
            title: todoData['title'] ?? 'New Task',
            description: todoData['description'] ?? '',
            priority: _parsePriority(todoData['priority']),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            chatSessionId: chatSessionId,
            aiContext: todoData['aiContext'],
            tags: List<String>.from(todoData['tags'] ?? []),
            dueDate: todoData['dueDate'] != null 
                ? DateTime.tryParse(todoData['dueDate']) 
                : null,
          );
        }
      }
    } catch (e) {
      debugPrint('Error generating TODO from message: $e');
    }
    
    return null;
  }
}
