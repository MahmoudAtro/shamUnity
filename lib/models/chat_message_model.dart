import 'package:shamunity/models/user_message.dart';

class ChatMessageModel {
  final int id;
  final String content;
  final String type;
  final UserMessage sender;
  final bool isRead;
  final DateTime createdAt;
  final int? conversationId;
  final String? fileUrl;

  ChatMessageModel(
      {required this.id,
      required this.content,
      required this.sender,
      required this.createdAt,
      required this.type,
      this.conversationId,
      this.fileUrl,
      required this.isRead});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
        id: json['id'],
        content: json['content'] ?? '',
        type: json['type'],
        sender: UserMessage.fromJson(json['sender']),
        createdAt: DateTime.parse(json['created_at']),
        conversationId: json['conversation_id'] ?? 0,
        isRead: json['is_read'],
        fileUrl: json['file_url'] ?? '');
  }ChatMessageModel copyWith({
    int? id,
    String? content,
    String? type,
    UserMessage? sender,
    DateTime? createdAt,
    int? conversationId,
    String? fileUrl,
    bool? isRead
  }) {
    return ChatMessageModel(
        id: id ?? this.id,
        content: content ?? this.content,
        type: type ?? this.type,
        sender: sender ?? this.sender,
        createdAt: createdAt ?? this.createdAt,
        conversationId: conversationId ?? this.conversationId,
        fileUrl: fileUrl ?? this.fileUrl,
        isRead: isRead ?? this.isRead);
  }

  List<Object?> get props => [id, content, type, sender, createdAt];
}
