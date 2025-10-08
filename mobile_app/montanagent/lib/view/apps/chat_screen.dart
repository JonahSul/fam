import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../controller/apps/chat_controller.dart';
import '../../helpers/widgets/my_spacing.dart';
import '../../helpers/widgets/my_text.dart';
import '../../helpers/widgets/my_card.dart';
import '../../helpers/widgets/my_button.dart';
import '../layouts/layout.dart';
import '../../services/firestore_service.dart';
import '../../services/session_service.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder<ChatController>(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              // Header
              Padding(
                padding: MySpacing.x(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium("Chat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              MySpacing.height(16),

              // Chat content
              Expanded(
                child: MyCard(
                  paddingAll: 0,
                  child: Column(
                    children: [
                      // Chat messages area
                      Expanded(
                        child: controller.selectChat == null
                            ? _buildEmptyState()
                            : _buildMessagesList(),
                      ),

                      // Message input
                      _buildMessageInput(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 64,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          MySpacing.height(16),
          MyText.titleMedium(
            'Start a conversation',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          MySpacing.height(8),
          MyText.bodyMedium(
            'Type a message below to begin chatting with MontaNAgent.',
            textAlign: TextAlign.center,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: MySpacing.all(16),
      itemCount: controller.selectChat?.messages.length ?? 0,
      itemBuilder: (context, index) {
        final message = controller.selectChat!.messages[index];
        return _buildMessage(message);
      },
    );
  }

  Widget _buildMessage(dynamic message) {
    // Handle both ChatMessageModel from demo app and our ChatMessage
    final isUser = message.fromMe == true || message.isUser == true;
    final messageText = message.message ?? '';

    return Container(
      margin: MySpacing.bottom(12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.smart_toy,
                size: 20,
                color: Colors.white,
              ),
            ),
            MySpacing.width(12),
          ],
          Flexible(
            child: MyCard(
              color: isUser
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
              borderRadiusAll: 16,
              paddingAll: 12,
              child: MyText.bodyMedium(messageText),
            ),
          ),
          if (isUser) ...[
            MySpacing.width(12),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[400],
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: MySpacing.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: MySpacing.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          MySpacing.width(12),
          MyButton.medium(
            const Icon(Icons.send, size: 20),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();
      controller.sendMessage(message);
    }
  }
}
