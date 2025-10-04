import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? userId;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.userId,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatMessage(
      id: documentId,
      message: data['message'] ?? '',
      isUser: data['isUser'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
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

      await _db
          .collection('users')
          .doc(userId)
          .collection('chatMessages')
          .add(message.toMap());
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
}
