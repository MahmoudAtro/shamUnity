import 'package:equatable/equatable.dart';
import 'package:shamunity/models/conversation_model.dart';

abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object?> get props => [];
}

// حدث جلب المحادثات
class FetchConversations extends ConversationsEvent {
  final int userId;

  const FetchConversations({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class FetchConversationsAfterReturn extends ConversationsEvent {
  final int userId;

  const FetchConversationsAfterReturn({required this.userId});
  @override
  List<Object?> get props => [userId];
}

// حدث تحديث محادثة موجودة أو إضافة جديدة
class ConversationUpdated extends ConversationsEvent {
  final ConversationModel updatedConversation;

  const ConversationUpdated(this.updatedConversation);

  @override
  List<Object?> get props => [updatedConversation];
}

// حدث إنشاء محادثة جديدة
class CreateConversation extends ConversationsEvent {
  final int userId;

  const CreateConversation(this.userId);

  @override
  List<Object?> get props => [userId];
}

// حدث إعادة الاتصال
class ReconnectConversationPusher extends ConversationsEvent {}

// حدث إعادة تشغيل الاستماع
class RestartConversationListening extends ConversationsEvent {}
