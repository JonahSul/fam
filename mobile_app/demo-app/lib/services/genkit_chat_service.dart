import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GenkitChatService {
  static const String _baseUrl = 'http://localhost:3000';
  
  /// Send a message to the genkit service and get a response
  static Future<GenkitChatResponse> sendMessage({
    required String message,
    String? userId,
    bool agentMode = false,
  }) async {
    try {
      final requestBody = {
        'message': message,
        'userId': userId ?? 'demo-user',
        'agent': agentMode,
      };
      
      print('Sending message to genkit: $requestBody');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Genkit response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GenkitChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error calling genkit service: $e');
      throw Exception('Error calling genkit service: $e');
    }
  }

  /// Send multiple messages for conversation context
  static Future<GenkitChatResponse> sendMessages({
    required List<ChatMessage> messages,
    String? userId,
    bool agentMode = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'messages': messages.map((m) => m.toJson()).toList(),
          'userId': userId ?? 'demo-user',
          'agent': agentMode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GenkitChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to send messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling genkit service: $e');
    }
  }

  /// Check if the genkit service is available
  static Future<bool> isServiceAvailable() async {
    try {
      print('Checking genkit service availability at $_baseUrl/health');
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Health check response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error checking genkit service health: $e');
      return false;
    }
  }
}

class GenkitChatResponse {
  final String response;
  final String? timestamp;
  final String? model;
  final String? provider;
  final Map<String, dynamic>? usage;
  final List<dynamic>? toolExecutions;
  final List<dynamic>? suggestedActions;

  GenkitChatResponse({
    required this.response,
    this.timestamp,
    this.model,
    this.provider,
    this.usage,
    this.toolExecutions,
    this.suggestedActions,
  });

  factory GenkitChatResponse.fromJson(Map<String, dynamic> json) {
    return GenkitChatResponse(
      response: json['response'] ?? '',
      timestamp: json['timestamp'],
      model: json['model'],
      provider: json['provider'],
      usage: json['usage'],
      toolExecutions: json['toolExecutions'],
      suggestedActions: json['suggestedActions'],
    );
  }
}

class ChatMessage {
  final String role;
  final List<ChatContent> content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  factory ChatMessage.user(String text) {
    return ChatMessage(
      role: 'user',
      content: [ChatContent.text(text)],
    );
  }

  factory ChatMessage.assistant(String text) {
    return ChatMessage(
      role: 'assistant',
      content: [ChatContent.text(text)],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content.map((c) => c.toJson()).toList(),
    };
  }
}

class ChatContent {
  final String type;
  final String text;

  ChatContent({
    required this.type,
    required this.text,
  });

  factory ChatContent.text(String text) {
    return ChatContent(type: 'text', text: text);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
    };
  }
}
