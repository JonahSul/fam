import 'dart:async';

import 'package:flutter/material.dart';
import 'package:henox/controller/my_controller.dart';
import 'package:henox/helpers/utils/generator.dart';
import 'package:henox/model/chat_modal.dart';
import 'package:henox/services/genkit_chat_service.dart';

class ChatController extends MyController {
  List<ChatModel> chat = [];
  List<ChatModel> searchChat = [];
  ChatModel? selectChat;
  ScrollController? scrollController;
  SearchController searchController = SearchController();
  TextEditingController messageController = TextEditingController();
  late Timer _timer;
  int _nowTime = 0;
  String timeText = "00 : 00";
  bool isLoading = false;
  bool genkitServiceAvailable = false;

  @override
  void onInit() {
    ChatModel.dummyList.then((value) {
      chat = value;
      searchChat = value;
      selectChat = chat[0];
      update();
    });
    startTimer();
    scrollController = ScrollController();
    _checkGenkitService();
    super.onInit();
  }

  Future<void> _checkGenkitService() async {
    try {
      genkitServiceAvailable = await GenkitChatService.isServiceAvailable();
      print('Genkit service available: $genkitServiceAvailable');
      update();
    } catch (e) {
      print('Error checking genkit service: $e');
      genkitServiceAvailable = false;
      update();
    }
  }

  void onChangeChat(ChatModel selectSingleChat) {
    selectChat = selectSingleChat;
    update();
  }

  void onSearchChat(String query) {
    final input = query.toLowerCase();
    searchChat = chat
        .where((chat) =>
            chat.firstName.toLowerCase().contains(input) ||
            chat.messages.lastOrNull!.message.toLowerCase().contains(input))
        .toList();
    update();
  }

  Future<void> sendMessage() async {
    print('sendMessage called - text: "${messageController.value.text}", selectChat: ${selectChat != null}, genkitAvailable: $genkitServiceAvailable');
    
    if (messageController.value.text.isNotEmpty && selectChat != null) {
      final userMessage = messageController.text;

      // Add user message to chat
      selectChat!.messages.add(
          ChatMessageModel(-1, userMessage, DateTime.now(), true));
      messageController.clear();
      scrollToBottom(isDelayed: true);
      update();

      // If genkit service is available, get AI response
      if (genkitServiceAvailable) {
        print('Genkit service is available, sending message...');
        isLoading = true;
        update();

        try {
          final response = await GenkitChatService.sendMessage(
            message: userMessage,
            userId: 'demo-user-${selectChat!.id}',
            agentMode: false,
          );

          print('Received response from genkit: ${response.response}');
          // Add AI response to chat
          selectChat!.messages.add(
              ChatMessageModel(-1, response.response, DateTime.now(), false));
          scrollToBottom(isDelayed: true);
        } catch (e) {
          print('Error sending message to genkit: $e');
          // Add error message to chat
          selectChat!.messages.add(
              ChatMessageModel(-1, 'Sorry, I encountered an error: $e', DateTime.now(), false));
        } finally {
          isLoading = false;
          update();
        }
      } else {
        print('Genkit service is not available');
      }
    }
  }

  scrollToBottom({bool isDelayed = false}) {
    final int delay = isDelayed ? 400 : 0;
    Future.delayed(Duration(milliseconds: delay), () {
      scrollController!.animateTo(scrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubicEmphasized);
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      _nowTime = _nowTime + 1;
      timeText = Generator.getTextFromSeconds(time: _nowTime);
      update();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
