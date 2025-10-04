import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _webBaseUrl = String.fromEnvironment(
  'CHAT_SERVICE_URL',
  defaultValue: 'http://localhost:3000',
);
const String _androidBaseUrl = String.fromEnvironment(
  'CHAT_SERVICE_URL_ANDROID',
  defaultValue: 'http://10.0.2.2:3000',
);
const String _iosBaseUrl = String.fromEnvironment(
  'CHAT_SERVICE_URL_IOS',
  defaultValue: 'http://localhost:3000',
);
const String _desktopBaseUrl = String.fromEnvironment(
  'CHAT_SERVICE_URL_DESKTOP',
  defaultValue: 'http://localhost:3000',
);

class ChatService extends ChangeNotifier {
  bool _isLoading = false;
  late String _baseUrl;

  ChatService({String? baseUrl}) {
    _baseUrl = baseUrl ?? _computeDefaultBaseUrl();
  }

  bool get isLoading => _isLoading;

  // Set the base URL for the GenKit service
  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  String _computeDefaultBaseUrl() {
    if (kIsWeb) {
      return _webBaseUrl;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidBaseUrl;
      case TargetPlatform.iOS:
        return _iosBaseUrl;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return _desktopBaseUrl;
      case TargetPlatform.fuchsia:
        return _desktopBaseUrl;
    }
  }

  // Send a message to the GenKit service
  Future<String> sendMessage(String message, {String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': message,
          'userId': userId ?? 'anonymous',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] ?? 'No response received';
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Chat service error: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Error sending message to chat service: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if the service is available
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }
}