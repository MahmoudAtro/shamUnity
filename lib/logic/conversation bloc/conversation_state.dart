
import 'package:shamunity/models/conversation_model.dart';

abstract class ConversationsState {}

// Initial state when the cubit is first created
class ConversationsInitial extends ConversationsState {}

// Loading state when fetching conversations
class ConversationsLoading extends ConversationsState {}

// Success state when conversations are loaded successfully
class ConversationsLoaded extends ConversationsState {
  final List<ConversationModel> conversations;
  
  ConversationsLoaded({required this.conversations});
}

class ConversationsAddLoaded extends ConversationsState {
  final ConversationResponseModel conversations;

  ConversationsAddLoaded(this.conversations);
}

// Error state when something goes wrong
class ConversationsError extends ConversationsState {
  final String message;
  
  ConversationsError(this.message);
}