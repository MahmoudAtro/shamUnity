import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/chat/chat.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/logic/chat%20bloc/chat_event.dart';
import 'package:shamunity/logic/chat%20bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Chat chat;
  final ChatMessagePusher pusherService;
  StreamSubscription? _messageSubscription;
  bool _isListening = false; // متابعة حالة الاستماع

  ChatBloc({required this.chat, required this.pusherService})
      : super(ChatInitial()) {
    // ربط الأحداث بالدوال فقط - بدون تشغيل الاستماع
    on<FetchChat>(_onFetchChats);
    on<SendMessage>(_onSendMessage);
    on<ChatUpdate>(_onChatUpdated);

    debugPrint("🚀 ChatBloc: تم إنشاؤه بنجاح");
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    BuildContext? context = SingleInstanceService.context;
    final result = await chat.sendMessage(
      event.userId,
      event.type,
      content: event.content,
      attachment: event.attachment,
    );
    result.fold((failure) {
      Toast().error(context!, failure.message);
    }, (data) {
      debugPrint("تم ارسال الرسالة بنجاح");
    });
  }

  Future<void> _onFetchChats(FetchChat event, Emitter<ChatState> emit) async {
    debugPrint("📥 ChatBloc: بدء جلب الرسائل للمحادثة ${event.conversationId}");

    emit(ChatLoading());

    try {
      // 1. تهيئة Pusher أولاً
      debugPrint("🔄 ChatBloc: تهيئة Pusher...");
      await pusherService.init();
      debugPrint("✅ ChatBloc: تم تهيئة Pusher بنجاح");

      // 2. بدء الاستماع للرسائل بعد التهيئة
      if (!_isListening) {
        debugPrint("👂 ChatBloc: بدء الاستماع للرسائل...");
        _startListeningToMessages();
      }

      // 3. الاشتراك في القناة
      debugPrint(
          "📡 ChatBloc: الاشتراك في قناة المحادثة ${event.conversationId}");
      await pusherService.subscribeToConversation(event.conversationId);
      debugPrint("✅ ChatBloc: تم الاشتراك في القناة بنجاح");

      // 4. جلب الرسائل الموجودة من API
      debugPrint("🔄 ChatBloc: جلب الرسائل من الخادم...");
      final result = await chat.getMessages(event.conversationId);

      result.fold(
        (failure) {
          debugPrint("❌ ChatBloc: فشل في جلب الرسائل: ${failure.message}");
          emit(ChatError(failure.message));
        },
        (messages) {
          debugPrint("✅ ChatBloc: تم جلب ${messages.length} رسالة بنجاح");
          emit(ChatLoaded(chats: messages));

          // اختبار الاتصال بعد التحميل
          _testConnection(event.conversationId);
        },
      );
    } catch (e) {
      debugPrint("❌ ChatBloc: خطأ في التهيئة: $e");
      emit(ChatError("فشل في تهيئة المحادثة: $e"));
    }
  }

  // دالة منفصلة لبدء الاستماع
  void _startListeningToMessages() {
    if (_isListening) {
      debugPrint("ℹ️ ChatBloc: الاستماع مُفعل بالفعل");
      return;
    }

    debugPrint("🎧 ChatBloc: إعداد مستمع الرسائل...");

    _messageSubscription = pusherService.messagesStream.listen(
      (message) {
        debugPrint("📨 ChatBloc: استلام رسالة جديدة:");
        debugPrint("   🆔 ID: ${message.id}");
        debugPrint("   💬 المحتوى: ${message.content}");
        debugPrint("   👤 المرسل: ${message.sender.name}");
        debugPrint("   ⏰ الوقت: ${message.createdAt}");

        // إضافة الرسالة للـ BLoC
        add(ChatUpdate(message));
      },
      onError: (error) {
        debugPrint("❌ ChatBloc: خطأ في مجرى الرسائل: $error");
      },
      onDone: () {
        debugPrint("🔚 ChatBloc: انتهى مجرى الرسائل");
        _isListening = false;
      },
    );

    _isListening = true;
    debugPrint("✅ ChatBloc: تم تفعيل مستمع الرسائل");
  }

  void _onChatUpdated(ChatUpdate event, Emitter<ChatState> emit) {
    debugPrint("🔄 ChatBloc: تحديث المحادثة برسالة جديدة");

    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      // التحقق من عدم تكرار الرسالة
      final exists =
          currentState.chats.any((msg) => msg.id == event.message.id);

      if (exists) {
        debugPrint("ℹ️ ChatBloc: الرسالة موجودة بالفعل، تم تجاهل التحديث");
        return; // لا تفعل أي شيء
      }

      // إذا لم تكن موجودة، أضف الرسالة للقائمة الحالية
      final updatedChats = [event.message, ...currentState.chats];
      emit(ChatLoaded(chats: updatedChats));
      debugPrint("✅ ChatBloc: تم إضافة رسالة جديدة بنجاح");
    } else {
      debugPrint(
          "⚠️ ChatBloc: الحالة الحالية ليست ChatLoaded - النوع: ${state.runtimeType}");

      // إذا لم تكن الحالة محملة، قم بإنشاء قائمة جديدة بالرسالة
      emit(ChatLoaded(chats: [event.message]));
      debugPrint("✅ ChatBloc: تم إنشاء الحالة وإضافة الرسالة");
    }
    debugPrint("📋 القائمة الجديدة:");
    debugPrint("  [0] ID: ${event.message.id} - النص: ${event.message.content} - الصورة: ${event.message.fileUrl}");
  }

  // دالة اختبار الاتصال
  void _testConnection(chatId) {
    Timer(const Duration(seconds: 2), () {
      debugPrint("🧪 ChatBloc: اختبار حالة الاتصال:");
      debugPrint("   🔌 Pusher متصل: ${pusherService.isConnected}");
      debugPrint(
          "   📺 القنوات المشتركة: ${pusherService.subscribeToConversation(chatId)}");
      debugPrint("   👂 يستمع للرسائل: $_isListening");
      debugPrint(
          "   🎯 المجرى له مستمعين: ${pusherService.messageStreamController.hasListener}");
    });
  }

  // إيقاف الاستماع
  void _stopListening() {
    if (_messageSubscription != null) {
      _messageSubscription?.cancel();
      _messageSubscription = null;
      _isListening = false;
      debugPrint("🛑 ChatBloc: تم إيقاف الاستماع للرسائل");
    }
  }

  @override
  Future<void> close() {
    debugPrint("🔚 ChatBloc: إغلاق البلوك...");

    _stopListening();
    pusherService.disconnect();

    debugPrint("✅ ChatBloc: تم الإغلاق بنجاح");
    return super.close();
  }

  // دوال مساعدة للوصول إلى المعلومات
  bool get isListeningToMessages => _isListening;
  bool get isPusherConnected => pusherService.isConnected;

  // دالة لإعادة تشغيل الاستماع يدوياً
  void restartListening() {
    debugPrint("🔄 ChatBloc: إعادة تشغيل الاستماع...");
    _stopListening();
    _startListeningToMessages();
  }
}
