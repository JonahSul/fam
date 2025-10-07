import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/firestore_service.dart';
import '../../services/session_service.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../model/chat_modal.dart';

class ChatController extends GetxController {
  // Services
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final SessionService _sessionService = Get.find<SessionService>();
  final ChatService _chatService = Get.find<ChatService>();
  final AuthService _authService = Get.find<AuthService>();

  // UI State
  ScrollController? scrollController;
  bool isLoading = false;
  String timeText = "00 : 00";

  // Chat data (using demo structure but with real data)
  List<ChatModel> chat = [];
  List<ChatModel> searchChat = [];
  ChatModel? selectChat;

  // Current session messages
  List<dynamic> currentMessages = [];
  StreamSubscription? _messagesSubscription;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    _initializeChat();
    startTimer();
  }

  Future<void> _initializeChat() async {
    // Create a simple chat structure for the current session
    final chatModel = ChatModel(
      id: 1,
      firstName: 'MontaNAgent',
      lastName: 'AI',
      image: 'assets/images/users/avatar-1.jpg',
      messages: [],
      isOnline: true,
      unreadCount: 0,
    );

    chat = [chatModel];
    searchChat = [chatModel];
    selectChat = chatModel;

    // Load messages for current session
    _loadSessionMessages();

    update();
  }

  void _loadSessionMessages() {
    if (!_sessionService.hasActiveSession) {
      return;
    }

    _messagesSubscription?.cancel();
    _messagesSubscription = _sessionService.getCurrentSessionMessages().listen((messages) {
      currentMessages = messages;
      if (selectChat != null) {
        // Convert Firestore messages to ChatMessageModel format for display
        selectChat!.messages = messages.map((msg) {
          return ChatMessageModel(
            msg.isUser ? -1 : 1, // Use negative for user, positive for AI
            msg.message,
            msg.timestamp,
            msg.isUser,
          );
        }).toList();
        update();
      }
    });
  }

  void sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    if (!_sessionService.hasActiveSession) {
      // Auto-create session if none exists
      try {
        await _sessionService.startNewSession();
        _loadSessionMessages();
      } catch (e) {
        print('Error creating session: $e');
        return;
      }
    }

    isLoading = true;
    update();

    try {
      // Send message through chat service
      await _chatService.sendMessage(messageText);

      // The response will be handled by the session service listener
      // No need to manually add messages here
    } catch (e) {
      print('Error sending message: $e');
      // Show error to user
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  void onSearchChat(String query) {
    final input = query.toLowerCase();
    searchChat = chat
        .where((chat) =>
            chat.firstName.toLowerCase().contains(input) ||
            chat.messages.lastOrNull?.message.toLowerCase().contains(input) == true)
        .toList();
    update();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer timer) {
      final now = DateTime.now();
      final minutes = now.minute.toString().padLeft(2, '0');
      final seconds = now.second.toString().padLeft(2, '0');
      timeText = "$minutes : $seconds";
      update();
    });
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    scrollController?.dispose();
    super.onClose();
  }
}
