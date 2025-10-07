import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/firestore_service.dart' show ChatMessage;
import '../models/todo_item.dart';

/// Service for managing agent mode functionality
/// Allows AI agents to execute tools to complete TODO items on behalf of users
class AgentModeService extends ChangeNotifier {
  final String baseUrl;
  bool _isEnabled = false;
  bool _isProcessing = false;
  List<ToolExecution> _executionHistory = [];
  List<ToolExecution> _activeExecutions = [];

  AgentModeService({String? baseUrl}) : baseUrl = baseUrl ?? 'http://localhost:3000';

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isProcessing => _isProcessing;
  List<ToolExecution> get executionHistory => List.unmodifiable(_executionHistory);
  List<ToolExecution> get activeExecutions => List.unmodifiable(_activeExecutions);

  /// Initialize agent mode service
  Future<void> initialize() async {
    try {
      await _loadConfiguration();
      await _loadExecutionHistory();
      debugPrint('✅ Agent mode service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing agent mode service: $e');
    }
  }

  /// Load agent mode configuration
  Future<void> _loadConfiguration() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agent-mode/config'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isEnabled = data['enabled'] ?? false;
        notifyListeners();
      } else {
        debugPrint('Server returned status ${response.statusCode} for agent mode config');
      }
    } catch (e) {
      debugPrint('Error loading agent mode configuration (server may not be available): $e');
      // Default to disabled if server is not available
      _isEnabled = false;
    }
  }

  /// Load execution history
  Future<void> _loadExecutionHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agent-mode/executions'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _executionHistory = (data['history'] as List)
            .map((item) => ToolExecution.fromMap(item))
            .toList();
        _activeExecutions = (data['active'] as List)
            .map((item) => ToolExecution.fromMap(item))
            .toList();
        notifyListeners();
      } else {
        debugPrint('Server returned status ${response.statusCode} for execution history');
      }
    } catch (e) {
      debugPrint('Error loading execution history (server may not be available): $e');
      // Initialize with empty lists if server is not available
      _executionHistory = [];
      _activeExecutions = [];
    }
  }

  /// Process a message in agent mode
  Future<AgentModeResponse> processMessageWithAgentMode({
    required List<ChatMessage> messages,
    required String chatSessionId,
    required String userId,
    List<TodoItem>? currentTodos,
    Map<String, dynamic>? userPreferences,
  }) async {
    if (!_isEnabled) {
      throw Exception('Agent mode is not enabled');
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agent-mode/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'messages': messages.map((m) => m.toMap()).toList(),
          'chatSessionId': chatSessionId,
          'userId': userId,
          'currentTodos': currentTodos?.map((t) => t.toMap()).toList(),
          'userPreferences': userPreferences,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update execution history
        final toolExecutions = (data['toolExecutions'] as List)
            .map((item) => ToolExecution.fromMap(item))
            .toList();

        _executionHistory.addAll(toolExecutions);
        _activeExecutions.removeWhere((exec) =>
            toolExecutions.any((newExec) => newExec.id == exec.id));

        notifyListeners();

        return AgentModeResponse.fromMap(data);
      } else {
        throw Exception('Failed to process agent mode message: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error processing agent mode message: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Execute a tool for a specific TODO
  Future<ToolExecution> executeToolForTodo({
    required String todoId,
    required String toolName,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agent-mode/execute-tool-for-todo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'todoId': todoId,
          'toolName': toolName,
          'parameters': parameters,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final execution = ToolExecution.fromMap(data['execution']);

        _executionHistory.add(execution);
        notifyListeners();

        return execution;
      } else {
        throw Exception('Failed to execute tool for TODO: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error executing tool for TODO: $e');
      rethrow;
    }
  }

  /// Enable or disable agent mode
  Future<void> setEnabled(bool enabled) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agent-mode/config'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'enabled': enabled}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _isEnabled = enabled;
        notifyListeners();
      } else {
        debugPrint('Server returned status ${response.statusCode} for setEnabled');
      }
    } catch (e) {
      debugPrint('Error updating agent mode configuration: $e');
    }
  }

  /// Update agent mode configuration
  Future<void> updateConfiguration({
    bool? enabled,
    int? maxConcurrentExecutions,
    List<String>? allowedTools,
    bool? requireUserConfirmation,
    bool? autoExecute,
  }) async {
    try {
      final config = <String, dynamic>{};
      if (enabled != null) config['enabled'] = enabled;
      if (maxConcurrentExecutions != null) config['maxConcurrentExecutions'] = maxConcurrentExecutions;
      if (allowedTools != null) config['allowedTools'] = allowedTools;
      if (requireUserConfirmation != null) config['requireUserConfirmation'] = requireUserConfirmation;
      if (autoExecute != null) config['autoExecute'] = autoExecute;

      final response = await http.post(
        Uri.parse('$baseUrl/agent-mode/config'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(config),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isEnabled = data['config']['enabled'] ?? _isEnabled;
        notifyListeners();
      } else {
        debugPrint('Server returned status ${response.statusCode} for updateConfiguration');
      }
    } catch (e) {
      debugPrint('Error updating agent mode configuration: $e');
    }
  }

  /// Get execution history
  Future<void> refreshExecutionHistory() async {
    await _loadExecutionHistory();
  }

  /// Clear execution history
  void clearExecutionHistory() {
    _executionHistory.clear();
    _activeExecutions.clear();
    notifyListeners();
  }
}

/// Represents a tool execution
class ToolExecution {
  final String id;
  final String toolName;
  final Map<String, dynamic> parameters;
  final ToolExecutionStatus status;
  final dynamic result;
  final String? error;
  final DateTime timestamp;
  final String? todoId;

  ToolExecution({
    required this.id,
    required this.toolName,
    required this.parameters,
    required this.status,
    this.result,
    this.error,
    required this.timestamp,
    this.todoId,
  });

  factory ToolExecution.fromMap(Map<String, dynamic> data) {
    return ToolExecution(
      id: data['id'] ?? '',
      toolName: data['toolName'] ?? '',
      parameters: Map<String, dynamic>.from(data['parameters'] ?? {}),
      status: ToolExecutionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ToolExecutionStatus.pending,
      ),
      result: data['result'],
      error: data['error'],
      timestamp: DateTime.parse(data['timestamp']),
      todoId: data['todoId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'toolName': toolName,
      'parameters': parameters,
      'status': status.name,
      'result': result,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
      'todoId': todoId,
    };
  }

  bool get isCompleted => status == ToolExecutionStatus.completed;
  bool get isFailed => status == ToolExecutionStatus.failed;
  bool get isExecuting => status == ToolExecutionStatus.executing;
  bool get isPending => status == ToolExecutionStatus.pending;
}

/// Tool execution status
enum ToolExecutionStatus {
  pending,
  executing,
  completed,
  failed,
}

/// Response from agent mode processing
class AgentModeResponse {
  final ChatMessage response;
  final List<ToolExecution> toolExecutions;
  final List<String> suggestedActions;
  final DateTime timestamp;

  AgentModeResponse({
    required this.response,
    required this.toolExecutions,
    required this.suggestedActions,
    required this.timestamp,
  });

  factory AgentModeResponse.fromMap(Map<String, dynamic> data) {
    return AgentModeResponse(
      response: ChatMessage(
        id: data['response']?['id'] ?? '',
        // Backend returns ChatResponse with 'text'; fall back if 'message' absent
        message: (data['response']?['message'] ?? data['response']?['text'] ?? '').toString(),
        isUser: data['response']?['isUser'] ?? false,
        timestamp: DateTime.tryParse(data['response']?['timestamp'] ?? '') ?? DateTime.now(),
        userId: data['response']?['userId'],
        chatSessionId: data['response']?['chatSessionId'],
        metadata: Map<String, dynamic>.from(data['response']?['metadata'] ?? {}),
      ),
      toolExecutions: (data['toolExecutions'] as List)
          .map((item) => ToolExecution.fromMap(item))
          .toList(),
      suggestedActions: List<String>.from(data['suggestedActions'] ?? []),
      timestamp: DateTime.parse(data['timestamp']),
    );
  }
}
