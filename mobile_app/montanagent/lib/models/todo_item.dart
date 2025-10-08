import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a TODO item generated from chat conversations
enum TodoStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

enum TodoPriority {
  low,
  medium,
  high,
  urgent,
}

/// Represents a TODO item with AI-generated context
class TodoItem {
  final String id;
  final String title;
  final String description;
  final TodoStatus status;
  final TodoPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final String? chatSessionId;
  final String? userId;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final String? aiContext; // AI-generated context about why this TODO was created

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    this.status = TodoStatus.pending,
    this.priority = TodoPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.chatSessionId,
    this.userId,
    this.tags = const [],
    this.metadata = const {},
    this.aiContext,
  });

  factory TodoItem.fromMap(Map<String, dynamic> data, String documentId) {
    return TodoItem(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: TodoStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TodoStatus.pending,
      ),
      priority: TodoPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TodoPriority.medium,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null 
          ? (data['dueDate'] as Timestamp).toDate() 
          : null,
      chatSessionId: data['chatSessionId'],
      userId: data['userId'],
      tags: List<String>.from(data['tags'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      aiContext: data['aiContext'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'chatSessionId': chatSessionId,
      'userId': userId,
      'tags': tags,
      'metadata': metadata,
      'aiContext': aiContext,
    };
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    TodoStatus? status,
    TodoPriority? priority,
    DateTime? updatedAt,
    DateTime? dueDate,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? aiContext,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      chatSessionId: chatSessionId,
      userId: userId,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      aiContext: aiContext ?? this.aiContext,
    );
  }

  /// Get a human-readable status
  String get statusDisplayName {
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

  /// Get a human-readable priority
  String get priorityDisplayName {
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

  /// Get priority color for UI
  int get priorityColor {
    switch (priority) {
      case TodoPriority.low:
        return 0xFF4CAF50; // Green
      case TodoPriority.medium:
        return 0xFF2196F3; // Blue
      case TodoPriority.high:
        return 0xFFFF9800; // Orange
      case TodoPriority.urgent:
        return 0xFFF44336; // Red
    }
  }
}
