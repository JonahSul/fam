import 'package:flutter/foundation.dart';
import '../models/chat_session.dart';
import '../models/todo_item.dart';
import 'firestore_service.dart';
import 'todo_ai_service.dart';

/// Service to manage the current chat session and TODO generation
class SessionService extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final TodoAIService _todoAIService;
  
  ChatSession? _currentSession;
  List<TodoItem> _currentSessionTodos = [];
  bool _isLoading = false;

  SessionService(this._firestoreService, this._todoAIService);

  // Getters
  ChatSession? get currentSession => _currentSession;
  List<TodoItem> get currentSessionTodos => _currentSessionTodos;
  bool get isLoading => _isLoading;
  bool get hasActiveSession => _currentSession != null;

  /// Start a new chat session
  Future<ChatSession> startNewSession({String? title}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _firestoreService.createChatSession(title: title);
      _currentSession = session;
      _currentSessionTodos = [];
      
      debugPrint('✅ Started new chat session: ${session.id}');
      return session;
    } catch (e) {
      debugPrint('❌ Error starting new session: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resume an existing chat session
  Future<void> resumeSession(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _firestoreService.getChatSession(sessionId);
      if (session != null) {
        _currentSession = session;
        
        // Load TODOs for this session
        await _loadSessionTodos();
        
        debugPrint('✅ Resumed chat session: ${session.id}');
      } else {
        throw Exception('Session not found');
      }
    } catch (e) {
      debugPrint('❌ Error resuming session: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load TODOs for the current session
  Future<void> _loadSessionTodos() async {
    if (_currentSession == null) return;

    try {
      _firestoreService.getTodosForSession(_currentSession!.id).listen((todos) {
        _currentSessionTodos = todos;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('❌ Error loading session TODOs: $e');
    }
  }

  /// Generate TODOs from the current conversation
  Future<List<TodoItem>> generateTodosFromConversation(List<ChatMessage> messages) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    try {
      final todos = await _todoAIService.generateTodosFromChat(
        chatSessionId: _currentSession!.id,
        messages: messages,
      );

      // Update the current session TODOs
      _currentSessionTodos.addAll(todos);
      notifyListeners();

      debugPrint('✅ Generated ${todos.length} TODOs for session ${_currentSession!.id}');
      return todos;
    } catch (e) {
      debugPrint('❌ Error generating TODOs: $e');
      rethrow;
    }
  }

  /// Generate a TODO from a single message
  Future<TodoItem?> generateTodoFromMessage(String message) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    try {
      final todo = await _todoAIService.generateTodoFromMessage(
        message: message,
        chatSessionId: _currentSession!.id,
      );

      if (todo != null) {
        // Save the TODO to Firestore
        final savedTodo = await _firestoreService.createTodoItem(
          title: todo.title,
          description: todo.description,
          priority: todo.priority,
          chatSessionId: _currentSession!.id,
          aiContext: todo.aiContext,
          tags: todo.tags,
          dueDate: todo.dueDate,
        );

        // Update the current session TODOs
        _currentSessionTodos.add(savedTodo);
        notifyListeners();

        debugPrint('✅ Generated TODO from message: ${savedTodo.title}');
        return savedTodo;
      }
    } catch (e) {
      debugPrint('❌ Error generating TODO from message: $e');
    }

    return null;
  }

  /// Update a TODO item
  Future<void> updateTodo(TodoItem todo) async {
    try {
      await _firestoreService.updateTodoItem(todo);
      
      // Update in local list
      final index = _currentSessionTodos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _currentSessionTodos[index] = todo;
        notifyListeners();
      }
      
      debugPrint('✅ Updated TODO: ${todo.title}');
    } catch (e) {
      debugPrint('❌ Error updating TODO: $e');
      rethrow;
    }
  }

  /// Delete a TODO item
  Future<void> deleteTodo(String todoId) async {
    try {
      await _firestoreService.deleteTodoItem(todoId);
      
      // Remove from local list
      _currentSessionTodos.removeWhere((t) => t.id == todoId);
      notifyListeners();
      
      debugPrint('✅ Deleted TODO: $todoId');
    } catch (e) {
      debugPrint('❌ Error deleting TODO: $e');
      rethrow;
    }
  }

  /// Update the current session
  Future<void> updateCurrentSession({String? title}) async {
    if (_currentSession == null) return;

    try {
      final updatedSession = _currentSession!.copyWith(
        title: title,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateChatSession(updatedSession);
      _currentSession = updatedSession;
      notifyListeners();

      debugPrint('✅ Updated session: ${updatedSession.title}');
    } catch (e) {
      debugPrint('❌ Error updating session: $e');
      rethrow;
    }
  }

  /// End the current session
  Future<void> endCurrentSession() async {
    _currentSession = null;
    _currentSessionTodos = [];
    notifyListeners();
    
    debugPrint('✅ Ended current session');
  }

  /// Get all chat sessions for the user
  Stream<List<ChatSession>> getChatSessions() {
    return _firestoreService.getChatSessions();
  }

  /// Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _firestoreService.deleteChatSession(sessionId);
      
      // If this was the current session, end it
      if (_currentSession?.id == sessionId) {
        await endCurrentSession();
      }
      
      debugPrint('✅ Deleted session: $sessionId');
    } catch (e) {
      debugPrint('❌ Error deleting session: $e');
      rethrow;
    }
  }

  /// Get messages for the current session
  Stream<List<ChatMessage>> getCurrentSessionMessages() {
    if (_currentSession == null) {
      return Stream.value([]);
    }
    
    return _firestoreService.getChatMessagesForSession(_currentSession!.id);
  }
}
