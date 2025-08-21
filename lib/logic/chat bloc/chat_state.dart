import 'package:shamunity/models/chat_message_model.dart';

abstract class ChatState {}

// Initial state when the cubit is first created
class ChatInitial extends ChatState {}

// Loading state when fetching Chat
class ChatLoading extends ChatState {}

class ChatSendMessageSuccess extends ChatState {
  final int conversationId;

  ChatSendMessageSuccess({required this.conversationId});
}

class ChatCheckConversation extends ChatState {
  final int conversationId;

  ChatCheckConversation({required this.conversationId});
}

// Success state when Chat are loaded successfully
class ChatLoaded extends ChatState {
  final List<ChatMessageModel> chats;

  ChatLoaded({required this.chats});
}

// class ChatAddLoaded extends ChatState {
//   final ChatResponseModel Chat;

//   ChatAddLoaded(this.Chat);
// }

// Error state when something goes wrong
class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
