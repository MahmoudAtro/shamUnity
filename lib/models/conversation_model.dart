import 'package:shamunity/models/chat_message_model.dart';
import 'package:shamunity/models/user_message.dart';

class ConversationModel {
  final int id;
  final UserMessage participant;
  final ChatMessageModel? lastMessage;
  final DateTime updatedAt;
  final int? unreadCount;

  ConversationModel({
    required this.id,
    required this.participant,
    this.lastMessage,
    required this.updatedAt,
    required this.unreadCount
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participant: UserMessage.fromJson(json['participant']),
      lastMessage: json['last_message'] != null
          ? ChatMessageModel.fromJson(json['last_message'])
          : null,
        updatedAt: DateTime.parse(json['updated_at']),
        unreadCount: json['unread_count'] ?? 0,
    );
  }

  ConversationModel copyWith({
    int? id,
    UserMessage? participant,
    ChatMessageModel? lastMessage,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt,
      unreadCount: unreadCount
    );
  }

  List<Object?> get props => [id, participant, lastMessage];
}

class ConversationResponseModel {
  final int id;
  final UserMessage participant;
  final DateTime updatedAt;

  ConversationResponseModel({
    required this.id,
    required this.participant,
    required this.updatedAt,
  });

  factory ConversationResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ConversationResponseModel(
      id: data['id'] as int,
      participant:
          UserMessage.fromJson(data['participant'] as Map<String, dynamic>),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }
}
