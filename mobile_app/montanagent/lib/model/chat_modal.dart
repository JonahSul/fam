class ChatModel {
  final int id;
  final String firstName;
  final String lastName;
  final String image;
  List<ChatMessageModel> messages;
  final bool isOnline;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.messages,
    this.isOnline = true,
    this.unreadCount = 0,
  });
}

class ChatMessageModel {
  final int id;
  final String message;
  final DateTime sendAt;
  final bool fromMe;

  ChatMessageModel(this.id, this.message, this.sendAt, this.fromMe);
}
