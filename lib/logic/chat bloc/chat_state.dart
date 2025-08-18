
import 'package:shamunity/models/chat_message_model.dart';

abstract class ChatState {}

// Initial state when the cubit is first created
class ChatInitial extends ChatState {}

// Loading state when fetching Chat
class ChatLoading extends ChatState {}

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