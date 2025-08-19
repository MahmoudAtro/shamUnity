// Abstract base class for all conversation events
import 'dart:io';

import 'package:shamunity/models/chat_message_model.dart';

abstract class ChatEvent {}

// هذا الحدث يتم إرساله من الواجهة لجلب المحادثات لأول مرة
class FetchChat extends ChatEvent {
  final int? conversationId;

  FetchChat({required this.conversationId});
}

class CreateConversation extends ChatEvent {
  final int userId;

  CreateConversation({required this.userId});
}

class ReadAllMessage extends ChatEvent {
  final int conversationId;

  ReadAllMessage({required this.conversationId});
}

class DeleteMessage extends ChatEvent {
  final int messageId;

  DeleteMessage({required this.messageId});
}

class CheckConversation extends ChatEvent {
  final int userId;

  CheckConversation({required this.userId});
}

class DeleteMessageupdate extends ChatEvent {
  final int messageId;

  DeleteMessageupdate({required this.messageId});
}

// هذا حدث داخلي، سيقوم الـ BLoC بإضافته لنفسه عند وصول رسالة من Pusher
class ChatUpdate extends ChatEvent {
  final ChatMessageModel message;

  ChatUpdate(this.message);
}

class DeleteChannel extends ChatEvent {
  final int conversationId;

  DeleteChannel(this.conversationId);
}

class MessagesMarkedAsRead extends ChatEvent {
  final List<int> messageIds;

  MessagesMarkedAsRead({required this.messageIds});
}

class SendMessage extends ChatEvent {
  final int userId;
  final bool? isNewChat;
  final String? content;
  final File? attachment;
  final String type;

  SendMessage({
    required this.userId,
    this.content,
    required this.type,
    this.attachment,
    this.isNewChat
  });
}
