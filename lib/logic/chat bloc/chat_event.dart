// Abstract base class for all conversation events
import 'dart:io';

import 'package:shamunity/models/chat_message_model.dart';

abstract class ChatEvent {}

// هذا الحدث يتم إرساله من الواجهة لجلب المحادثات لأول مرة
class FetchChat extends ChatEvent {
  final int conversationId;

  FetchChat({required this.conversationId});
}

class CreateConversation extends ChatEvent {
  final int userId;

  CreateConversation({required this.userId});
}

// هذا حدث داخلي، سيقوم الـ BLoC بإضافته لنفسه عند وصول رسالة من Pusher
class ChatUpdate extends ChatEvent {
  final ChatMessageModel message;

  ChatUpdate(this.message);
}

class SendMessage extends ChatEvent {
  final int userId;
  final String? content;
  final File? attachment;
  final String type;

  SendMessage({
    required this.userId,
    this.content,
    required this.type,
    this.attachment,
  });
}
