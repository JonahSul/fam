import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chat session with MontaNAgent
/// Each session contains messages and associated TODOs
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;
  final List<String> messageIds;
  final List<String> todoIds;
  final Map<String, dynamic> metadata;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.messageIds = const [],
    this.todoIds = const [],
    this.metadata = const {},
  });

  factory ChatSession.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatSession(
      id: documentId,
      title: data['title'] ?? 'Untitled Chat',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      userId: data['userId'],
      messageIds: List<String>.from(data['messageIds'] ?? []),
      todoIds: List<String>.from(data['todoIds'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
      'messageIds': messageIds,
      'todoIds': todoIds,
      'metadata': metadata,
    };
  }

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? updatedAt,
    List<String>? messageIds,
    List<String>? todoIds,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId,
      messageIds: messageIds ?? this.messageIds,
      todoIds: todoIds ?? this.todoIds,
      metadata: metadata ?? this.metadata,
    );
  }
}
