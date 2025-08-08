class ChatItemModel {
  final String id;
  final String name;
  final String imageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatItemModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}
