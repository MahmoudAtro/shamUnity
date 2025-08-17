import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/chat/conversation.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/loading_dialog_widget.dart';
import 'package:shamunity/logic/conversation%20bloc/conversation_event.dart';
import 'package:shamunity/logic/conversation%20bloc/conversation_state.dart';
import 'package:shamunity/models/conversation_model.dart';
import 'package:shamunity/routes/extension.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final Conversation conversationRepository;
  final ConversationPusher conversationPusher;
  StreamSubscription? _conversationSubscription;
  bool _isListening = false; // متابعة حالة الاستماع

  ConversationsBloc({
    required this.conversationRepository,
    required this.conversationPusher,
  }) : super(ConversationsInitial()) {
    // ربط الأحداث بالدوال التي ستعالجها
    on<FetchConversations>(_onFetchConversations);
    on<FetchConversationsAfterReturn>(onFetchConversationsAfterReturn);
    on<ConversationUpdated>(_onConversationUpdated);
    on<CreateConversation>(_createConversation);
    debugPrint("🚀 ConversationsBloc: تم إنشاؤه بنجاح");
  }

  // Future<void> _onInitializePusher(
  //     InitializeConversationPusher event, Emitter<ConversationsState> emit) async {
  //   debugPrint("🔄 ConversationsBloc: تهيئة ConversationPusher...");

  //   _currentUserId = event.userId;

  //   try {
  //     // 1. تهيئة ConversationPusher أولاً
  //     debugPrint("🔄 ConversationsBloc: تهيئة Pusher...");
  //     await conversationPusher.init();
  //     debugPrint("✅ ConversationsBloc: تم تهيئة Pusher بنجاح");

  //     // 2. بدء الاستماع للمحادثات بعد التهيئة
  //     if (!_isListening) {
  //       debugPrint("👂 ConversationsBloc: بدء الاستماع للمحادثات...");
  //       _startListeningToConversations();
  //     }

  //     // 3. الاشتراك في قناة المستخدم
  //     debugPrint("📡 ConversationsBloc: الاشتراك في قناة المستخدم ${event.userId}");
  //     await conversationPusher.subscribeToUserConversations(event.userId);
  //     debugPrint("✅ ConversationsBloc: تم الاشتراك في قناة المستخدم بنجاح");

  //     debugPrint("✅ ConversationsBloc: تم تهيئة Pusher واستماع المحادثات بنجاح");
  //   } catch (e) {
  //     debugPrint("❌ ConversationsBloc: فشل في تهيئة Pusher: $e");
  //   }
  // }

  // دالة منفصلة لبدء الاستماع للمحادثات
  void _startListeningToConversations() {
    if (_isListening) {
      debugPrint("ℹ️ ConversationsBloc: الاستماع مُفعل بالفعل");
      return;
    }

    debugPrint("🎧 ConversationsBloc: إعداد مستمع المحادثات...");
    debugPrint(
        "   🔍 Stream صالح؟: ${!conversationPusher.conversationStreamController.isClosed}");

    _conversationSubscription = conversationPusher.conversationStream.listen(
      (conversation) {
        debugPrint("📨 ConversationsBloc: استلام تحديث محادثة من Stream");
        debugPrint("   🆔 ID: ${conversation.id}");
        debugPrint("   👤 المشارك: ${conversation.participant.name}");
        debugPrint(
            "   💬 آخر رسالة: ${conversation.lastMessage?.content ?? 'لا توجد رسالة'}");
        debugPrint("   📱 البلوك مُغلق؟: ${isClosed}");

        if (!isClosed) {
          // إضافة المحادثة المحدثة للـ BLoC
          add(ConversationUpdated(conversation));
          debugPrint("✅ ConversationsBloc: تم إضافة ConversationUpdated event");
        } else {
          debugPrint("❌ ConversationsBloc: البلوك مُغلق، لا يمكن إضافة الحدث");
        }
      },
      onError: (error) {
        debugPrint("❌ ConversationsBloc: خطأ في مجرى المحادثات: $error");
      },
      onDone: () {
        debugPrint("🔚 ConversationsBloc: انتهى مجرى المحادثات");
        // _isListening = false;
      },
    );

    _isListening = true;
    debugPrint("✅ ConversationsBloc: تم تفعيل مستمع المحادثات");
  }

  Future<void> _onFetchConversations(
      FetchConversations event, Emitter<ConversationsState> emit) async {
    debugPrint("📥 ChatBloc: بدء جلب الرسائل للمحادثة ${event.userId}");

    emit(ConversationsLoading());

    try {
      // 1. تهيئة Pusher أولاً
      debugPrint("🔄 conversationpusher: تهيئة Pusher...");
      await conversationPusher.init();
      debugPrint("✅ conversationpusher: تم تهيئة Pusher بنجاح");

      // 2. بدء الاستماع للرسائل بعد التهيئة
      if (!_isListening) {
        debugPrint("👂 ChatBloc: بدء الاستماع للرسائل...");
        _startListeningToConversations();
      }

      // 3. الاشتراك في القناة
      debugPrint("📡 ChatBloc: الاشتراك في قناة المحادثة ${event.userId}");
      await conversationPusher.subscribeToUserConversations(event.userId);
      debugPrint("✅ ChatBloc: تم الاشتراك في القناة بنجاح");

      // 4. جلب الرسائل الموجودة من API
      debugPrint("🔄 ChatBloc: جلب الرسائل من الخادم...");
      final result = await conversationRepository.getConversations();

      result.fold(
        (failure) {
          debugPrint("❌ ChatBloc: فشل في جلب الرسائل: ${failure.message}");
          emit(ConversationsError(failure.message));
        },
        (data) {
          debugPrint("✅ ChatBloc: تم جلب ${data.length} رسالة بنجاح");
          emit(ConversationsLoaded(conversations: data));

          // اختبار الاتصال بعد التحميل
          _testConnection(event.userId);
        },
      );
    } catch (e) {
      debugPrint("❌ ChatBloc: خطأ في التهيئة: $e");
      emit(ConversationsError("فشل في تهيئة المحادثة: $e"));
    }
  }

  Future<void> onFetchConversationsAfterReturn(
      FetchConversationsAfterReturn event,
      Emitter<ConversationsState> emit) async {
    debugPrint(
        "📥 ConversationsBloc: بدء جلب المحادثات بعد العودة للمستخدم ${event.userId}");

    try {
      // 1. إعادة اتصال Pusher أولاً
      debugPrint("🔄 ConversationsBloc: التحقق من حالة الاتصال...");
      // final connectionHealthy = await checkConnectionHealth(event.userId);

      if (conversationPusher.isConnected) {
        debugPrint(
            "⚠️ ConversationsBloc: اتصال غير صحي، إعادة الاتصال الكامل...");
        await fullReconnect(event.userId);
      } else {
        debugPrint("✅ ConversationsBloc: الاتصال صحي، متابعة...");
      }

      // 2. جلب المحادثات الموجودة من API
      debugPrint("🔄 ConversationsBloc: جلب المحادثات من الخادم...");
      final result = await conversationRepository.getConversations();

      result.fold(
        (failure) {
          debugPrint(
              "❌ ConversationsBloc: فشل في جلب المحادثات: ${failure.message}");
          emit(ConversationsError(failure.message));
        },
        (data) {
          debugPrint("✅ ConversationsBloc: تم جلب ${data.length} محادثة بنجاح");
          emit(ConversationsLoaded(conversations: data));

          // التأكد من أن الاستماع للمحادثات يعمل
          if (!_isListening) {
            debugPrint(
                "👂 ConversationsBloc: إعادة تشغيل الاستماع للمحادثات...");
            _startListeningToConversations();
          }

          // اختبار الاتصال بعد التحميل
          _testConnection(event.userId);
        },
      );
    } catch (e) {
      debugPrint("❌ ConversationsBloc: خطأ في جلب المحادثات بعد العودة: $e");
      emit(ConversationsError("فشل في جلب المحادثات بعد العودة: $e"));
    }
  }

  void _onConversationUpdated(
      ConversationUpdated event, Emitter<ConversationsState> emit) {
    debugPrint("🔄 ConversationsBloc: تحديث المحادثة");
    debugPrint("   🆔 محادثة ID: ${event.updatedConversation.id}");
    debugPrint(
        "   👤 المشارك: ${event.updatedConversation.lastMessage!.sender.name}");
    debugPrint("   📊 الحالة الحالية: ${state.runtimeType}");
    debugPrint("   📱 البلوك مُغلق؟: ${isClosed}"); // إضافة هذا السطر

    // تحقق من أن الحالة الحالية هي قائمة محملة
    if (state is ConversationsLoaded) {
      final currentState = state as ConversationsLoaded;
      final List<ConversationModel> currentList =
          List.from(currentState.conversations);

      debugPrint(
          "   📋 عدد المحادثات الحالية: ${currentList.length}"); // إضافة هذا السطر

      // ابحث عن المحادثة التي يجب تحديثها
      final int index = currentList
          .indexWhere((convo) => convo.id == event.updatedConversation.id);

      if (index != -1) {
        debugPrint(
            "✅ ConversationsBloc: تم العثور على المحادثة في القائمة، تحديث...");
        currentList.removeAt(index);
        currentList.insert(0, event.updatedConversation);

        // إضافة تتبع قبل وبعد emit
        debugPrint(
            "📤 ConversationsBloc: إرسال حالة جديدة مع ${currentList.length} محادثة");
        emit(ConversationsLoaded(conversations: currentList));
        debugPrint("✅ ConversationsBloc: تم إرسال الحالة الجديدة");
      } else {
        debugPrint("ℹ️ ConversationsBloc: محادثة جديدة غير موجودة في القائمة");
        currentList.insert(0, event.updatedConversation);

        debugPrint("📤 ConversationsBloc: إرسال حالة جديدة مع محادثة جديدة");
        emit(ConversationsLoaded(conversations: currentList));
        debugPrint("✅ ConversationsBloc: تم إرسال الحالة الجديدة");
      }
    } else {
      debugPrint(
          "⚠️ ConversationsBloc: الحالة الحالية ليست ConversationsLoaded");
      debugPrint("   📊 نوع الحالة الحالية: ${state.runtimeType}");

      emit(ConversationsLoaded(conversations: [event.updatedConversation]));
      debugPrint("✅ ConversationsBloc: تم إنشاء قائمة جديدة مع المحادثة");
    }
  }

  void _createConversation(
      CreateConversation event, Emitter<ConversationsState> emit) async {
    debugPrint(
        "🔄 ConversationsBloc: إنشاء محادثة جديدة مع المستخدم ${event.userId}");

    BuildContext? context = SingleInstanceService.context;
    showDialog(
        context: context!,
        builder: (BuildContext context) => const LoadingDialogWidget());

    try {
      final result =
          await conversationRepository.createConversation(event.userId);

      result.fold(
        (failure) {
          debugPrint(
              "❌ ConversationsBloc: فشل في إنشاء المحادثة: ${failure.message}");
          context.pop();
          emit(ConversationsError(failure.message));
          Toast().error(context, failure.message);
        },
        (conversation) {
          debugPrint(
              "✅ ConversationsBloc: تم إنشاء المحادثة بنجاح - ID: ${conversation.id}");

          // إضافة المحادثة الجديدة إلى الحالة الحالية
          context.pop();
          context.pushNamed('/userChatScreen', arguments: conversation);
          emit(ConversationsAddLoaded(conversation));

          // الاشتراك في المحادثة الجديدة (اختياري)
          conversationPusher.subscribeToSpecificConversation(conversation.id);
          debugPrint("📡 ConversationsBloc: تم الاشتراك في المحادثة الجديدة");
        },
      );
    } catch (e) {
      debugPrint("❌ ConversationsBloc: خطأ في إنشاء المحادثة: $e");
      context.pop();
      emit(ConversationsError("فشل في إنشاء المحادثة: $e"));
      Toast().error(context, "فشل في إنشاء المحادثة");
    }
  }

  // دالة اختبار الاتصال
  void _testConnection(int userId) {
    Timer(const Duration(seconds: 2), () {
      debugPrint("🧪 ConversationsBloc: اختبار حالة الاتصال:");
      debugPrint(
          "   🔌 ConversationPusher متصل: ${conversationPusher.isConnected}");
      debugPrint(
          "   📺 القنوات المشتركة: ${conversationPusher.subscribedChannels}");
      debugPrint("   👂 يستمع للمحادثات: $_isListening");
      debugPrint(
          "   🎯 المجرى له مستمعين: ${conversationPusher.conversationStreamController.hasListener}");
      debugPrint("   👤 معرف المستخدم الحالي: $userId");
    });
  }

  // إيقاف الاستماع
  void _stopListening() {
    if (_conversationSubscription != null) {
      _conversationSubscription?.cancel();
      _conversationSubscription = null;
      _isListening = false;
      debugPrint("🛑 ConversationsBloc: تم إيقاف الاستماع للمحادثات");
    }
  }

  // إعادة الاتصال في حالة الانقطاع
  // إضافة هذه الدالة للـ ConversationsBloc
  Future<void> fullReconnect(int userId) async {
    debugPrint("🔄 ConversationsBloc: إعادة اتصال كاملة...");

    try {
      // 1. إيقاف كل شيء
      _stopListening();
      await conversationPusher.disconnect();
      debugPrint("   🛑 تم قطع الاتصال");

      // 2. انتظار قصير
      await Future.delayed(Duration(milliseconds: 500));

      // 3. إعادة التهيئة الكاملة
      debugPrint("   🔄 إعادة تهيئة Pusher...");
      await conversationPusher.init();
      debugPrint("   ✅ تم إعادة تهيئة Pusher");

      // 4. التحقق من الاتصال
      if (!conversationPusher.isConnected) {
        debugPrint("   ❌ فشل في الاتصال، محاولة أخرى...");
        await conversationPusher
            .reconnect(); // إضافة دالة connect إن لم تكن موجودة
      }

      // 5. إعادة الاشتراك
      debugPrint("   📡 إعادة الاشتراك في القناة...");
      await conversationPusher.subscribeToUserConversations(userId);

      // 6. إعادة تشغيل الاستماع
      debugPrint("   👂 إعادة تشغيل الاستماع...");
      _startListeningToConversations();

      // 7. اختبار نهائي
      await Future.delayed(Duration(seconds: 1));
      _testConnection(userId);

      debugPrint("✅ ConversationsBloc: تمت إعادة الاتصال الكاملة بنجاح");
    } catch (e) {
      debugPrint("❌ ConversationsBloc: فشل في إعادة الاتصال الكاملة: $e");
    }
  }

  Future<void> restartListeningAfterReturn(int userId) async {
    debugPrint(
        "🔄 ConversationsBloc: إعادة تشغيل الاستماع بعد العودة من الشات...");

    try {
      // 1. التحقق من حالة الاتصال
      if (!conversationPusher.isConnected) {
        debugPrint("🔌 ConversationsBloc: Pusher غير متصل، إعادة الاتصال...");
        await conversationPusher.reconnect();
      }

      // 2. التحقق من الاشتراك في القناة
      final userChannelName = 'private-App.Models.User.$userId';
      if (!conversationPusher.subscribedChannels.contains(userChannelName)) {
        debugPrint("📡 ConversationsBloc: إعادة الاشتراك في قناة المستخدم...");
        await conversationPusher.subscribeToUserConversations(userId);
      }

      // 3. التأكد من تشغيل المستمع
      if (!_isListening) {
        debugPrint("👂 ConversationsBloc: إعادة تشغيل المستمع...");
        _startListeningToConversations();
      }

      // 4. اختبار الاتصال
      _testConnection(userId);

      debugPrint("✅ ConversationsBloc: تم إعادة تشغيل الاستماع بنجاح");
    } catch (e) {
      debugPrint("❌ ConversationsBloc: فشل في إعادة تشغيل الاستماع: $e");
    }
  }

  Future<bool> checkConnectionHealth(int userId) async {
    debugPrint("🔍 ConversationsBloc: فحص صحة الاتصال...");

    final isConnected = conversationPusher.isConnected;
    final hasSubscriptions = conversationPusher.subscribedChannels.isNotEmpty;
    final isListening = _isListening;
    final hasListeners =
        conversationPusher.conversationStreamController.hasListener;

    debugPrint("   🔌 متصل: $isConnected");
    debugPrint("   📡 لديه اشتراكات: $hasSubscriptions");
    debugPrint("   👂 يستمع: $isListening");
    debugPrint("   🎯 لديه مستمعين: $hasListeners");

    // ✅ التعديل المهم: يجب أن يكون Pusher متصلاً
    final isHealthy =
        isConnected && hasSubscriptions && isListening && hasListeners;
    debugPrint("   ✅ حالة الاتصال صحية: $isHealthy");

    return isHealthy;
  }

  @override
  Future<void> close() {
    debugPrint("🔚 ConversationsBloc: إغلاق البلوك...");

    _stopListening();
    conversationPusher.disconnect();

    debugPrint("✅ ConversationsBloc: تم الإغلاق بنجاح");
    return super.close();
  }

  // دوال مساعدة للوصول إلى المعلومات
  bool get isListeningToConversations => _isListening;
  bool get isPusherConnected => conversationPusher.isConnected;
  Set<String> get subscribedChannels => conversationPusher.subscribedChannels;

  // دالة لإعادة تشغيل الاستماع يدوياً
  void restartListening() {
    debugPrint("🔄 ConversationsBloc: إعادة تشغيل الاستماع...");
    _stopListening();
    _startListeningToConversations();
  }

  // دالة لإعادة جلب المحادثات وإعادة تهيئة Pusher
  void refreshConversations({int? userId}) {
    debugPrint("🔄 ConversationsBloc: تحديث شامل للمحادثات...");

    if (userId != null) {
      add(FetchConversations(userId: userId));
    }
  }
}
