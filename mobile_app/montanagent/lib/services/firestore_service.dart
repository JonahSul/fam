import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_session.dart';
import '../models/todo_item.dart';

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? userId;
  final String? chatSessionId;
  final Map<String, dynamic> metadata;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.userId,
    this.chatSessionId,
    this.metadata = const {},
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatMessage(
      id: documentId,
      message: data['message'] ?? '',
      isUser: data['isUser'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'],
      chatSessionId: data['chatSessionId'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'chatSessionId': chatSessionId,
      'metadata': metadata,
    };
  }
}

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save a chat message
  Future<void> saveChatMessage(ChatMessage message) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final docRef = await _db
          .collection('users')
          .doc(userId)
          .collection('chatMessages')
          .add(message.toMap());

      // Update the session to include this message ID
      if (message.chatSessionId != null) {
        await _updateSessionMessageIds(message.chatSessionId!, docRef.id);
      }
    } catch (e) {
      debugPrint('Error saving chat message: $e');
      rethrow;
    }
  }

  // Get chat messages for the current user
  Stream<List<ChatMessage>> getChatMessages() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('chatMessages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatMessage.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Clear chat history for the current user
  Future<void> clearChatHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _db.batch();
      final messages = await _db
          .collection('users')
          .doc(userId)
          .collection('chatMessages')
          .get();

      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
      rethrow;
    }
  }

  // Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _db.collection('users').doc(userId).set({
        'preferences': preferences,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      rethrow;
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _db.collection('users').doc(userId).get();
      return doc.data()?['preferences'];
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return null;
    }
  }

  // === CHAT SESSION MANAGEMENT ===

  /// Create a new chat session
  Future<ChatSession> createChatSession({String? title}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final session = ChatSession(
        id: '', // Will be set by Firestore
        title: title ?? 'NA Recovery Chat - ${_getFormattedDate(now)}',
        createdAt: now,
        updatedAt: now,
        userId: userId,
      );

      final docRef = await _db
          .collection('users')
          .doc(userId)
          .collection('chatSessions')
          .add(session.toMap());

      return session.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Error creating chat session: $e');
      rethrow;
    }
  }

  /// Get all chat sessions for the current user
  Stream<List<ChatSession>> getChatSessions() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('chatSessions')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatSession.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Get a specific chat session
  Future<ChatSession?> getChatSession(String sessionId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('chatSessions')
          .doc(sessionId)
          .get();

      if (!doc.exists) return null;
      return ChatSession.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('Error getting chat session: $e');
      return null;
    }
  }

  /// Update a chat session
  Future<void> updateChatSession(ChatSession session) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _db
          .collection('users')
          .doc(userId)
          .collection('chatSessions')
          .doc(session.id)
          .update(session.toMap());
    } catch (e) {
      debugPrint('Error updating chat session: $e');
      rethrow;
    }
  }

  /// Get messages for a specific chat session
  Stream<List<ChatMessage>> getChatMessagesForSession(String sessionId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('chatMessages')
        .where('chatSessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs.map((doc) {
            return ChatMessage.fromMap(doc.data(), doc.id);
          }).toList();
          
          // Sort by timestamp locally to avoid needing a composite index
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  // === TODO MANAGEMENT ===

  /// Create a new TODO item
  Future<TodoItem> createTodoItem({
    required String title,
    required String description,
    TodoPriority priority = TodoPriority.medium,
    String? chatSessionId,
    String? aiContext,
    List<String> tags = const [],
    DateTime? dueDate,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final todo = TodoItem(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        priority: priority,
        createdAt: now,
        updatedAt: now,
        chatSessionId: chatSessionId,
        userId: userId,
        aiContext: aiContext,
        tags: tags,
        dueDate: dueDate,
      );

      final docRef = await _db
          .collection('users')
          .doc(userId)
          .collection('todos')
          .add(todo.toMap());

      final savedTodo = todo.copyWith(id: docRef.id);

      // Update the session to include this TODO ID
      if (chatSessionId != null) {
        await _updateSessionTodoIds(chatSessionId, docRef.id);
      }

      return savedTodo;
    } catch (e) {
      debugPrint('Error creating TODO item: $e');
      rethrow;
    }
  }

  /// Get all TODO items for the current user
  Stream<List<TodoItem>> getTodos() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TodoItem.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Get TODO items for a specific chat session
  Stream<List<TodoItem>> getTodosForSession(String sessionId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .where('chatSessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) {
          final todos = snapshot.docs.map((doc) {
            return TodoItem.fromMap(doc.data(), doc.id);
          }).toList();
          
          // Sort by createdAt locally to avoid needing a composite index
          todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return todos;
        });
  }

  /// Update a TODO item
  Future<void> updateTodoItem(TodoItem todo) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _db
          .collection('users')
          .doc(userId)
          .collection('todos')
          .doc(todo.id)
          .update(todo.toMap());
    } catch (e) {
      debugPrint('Error updating TODO item: $e');
      rethrow;
    }
  }

  /// Delete a TODO item
  Future<void> deleteTodoItem(String todoId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get the TODO to find its session ID before deleting
      final todoDoc = await _db
          .collection('users')
          .doc(userId)
          .collection('todos')
          .doc(todoId)
          .get();

      if (todoDoc.exists) {
        final todoData = todoDoc.data()!;
        final sessionId = todoData['chatSessionId'] as String?;

        // Delete the TODO
        await _db
            .collection('users')
            .doc(userId)
            .collection('todos')
            .doc(todoId)
            .delete();

        // Remove the TODO ID from the session
        if (sessionId != null) {
          await _removeSessionTodoId(sessionId, todoId);
        }
      }
    } catch (e) {
      debugPrint('Error deleting TODO item: $e');
      rethrow;
    }
  }

  /// Delete a chat session and all associated data
  Future<void> deleteChatSession(String sessionId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _db.batch();

      // Delete the session
      batch.delete(_db
          .collection('users')
          .doc(userId)
          .collection('chatSessions')
          .doc(sessionId));

      // Delete all messages in the session
      final messages = await _db
          .collection('users')
          .doc(userId)
          .collection('chatMessages')
          .where('chatSessionId', isEqualTo: sessionId)
          .get();

      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete all TODOs in the session
      final todos = await _db
          .collection('users')
          .doc(userId)
          .collection('todos')
          .where('chatSessionId', isEqualTo: sessionId)
          .get();

      for (final doc in todos.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting chat session: $e');
      rethrow;
    }
  }

  /// Helper method to format dates for chat session titles
  String _getFormattedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Update session to include a new message ID
  Future<void> _updateSessionMessageIds(String sessionId, String messageId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final sessionRef = _db
          .collection('users')
          .doc(userId)
          .collection('chatSessions')
          .doc(sessionId);

      await sessionRef.update({
        'messageIds': FieldValue.arrayUnion([messageId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating session message IDs: $e');
    }
  }

  /// Update session to include a new TODO ID
  Future<void> _updateSessionTodoIds(String sessionId, String todoId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final sessionRef = _db
          .collection('users')
          .doc(userId)
          .collection('chatSessions')
          .doc(sessionId);

      await sessionRef.update({
        'todoIds': FieldValue.arrayUnion([todoId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating session TODO IDs: $e');
    }
  }

  /// Remove a TODO ID from session
  Future<void> _removeSessionTodoId(String sessionId, String todoId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final sessionRef = _db
          .collection('users')
          .doc(userId)
          .collection('chatSessions')
          .doc(sessionId);

      await sessionRef.update({
        'todoIds': FieldValue.arrayRemove([todoId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error removing session TODO ID: $e');
    }
  }
}
