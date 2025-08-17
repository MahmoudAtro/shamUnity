import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/conversation_model.dart';

class Conversation {
  final Dio _dio;

  Conversation({required Dio dio}) : _dio = dio;

  Future<Either<Failure, List<ConversationModel>>> getConversations() async {
    try {
      final response = await _dio.get(
        ApiConstances.getConversation,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );
      final List<ConversationModel> conversations =
          (response.data['data'] as List)
              .map((json) => ConversationModel.fromJson(json))
              .toList();
      return Right(conversations);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, ConversationResponseModel>> createConversation(
      int userId) async {
    try {
      final response = await _dio.post(
        ApiConstances.addConversation,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
        data: {
          'user_id': userId,
        },
      );
      final ConversationResponseModel conversations =
          ConversationResponseModel.fromJson(response.data);
      return Right(conversations);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }
}

class ConversationPusher {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final conversationStreamController =
      StreamController<ConversationModel>.broadcast();

  Stream<ConversationModel> get conversationStream => conversationStreamController.stream;

  // تتبع القنوات المشترك بها لتجنب الاشتراك المتكرر
  final Set<String> _subscribedChannels = <String>{};
  bool _isInitialized = false;

  Future<void> init() async {
    // تجنب إعادة التهيئة إذا كان مُهيأ بالفعل
    if (_isInitialized) {
      debugPrint("✅ ConversationPusher: Already initialized");
      return;
    }

    try {
      debugPrint("🔄 ConversationPusher: Starting initialization...");

      await _pusher.init(
          apiKey: "acaead266f9e5e8e34c9",
          cluster: "us3",
          useTLS: true,
          onConnectionStateChange: (currentState, previousState) {
            debugPrint(
                "🔄 Pusher connection state changed: $previousState -> $currentState");

            if (currentState == "CONNECTED" || currentState == "connected") {
              debugPrint("✅ Pusher conversation connected successfully");
            } else if (currentState == "DISCONNECTED" ||
                currentState == "disconnected") {
              debugPrint("❌ Pusher conversation disconnected");
            }
          },
          onError: (message, code, error) {
            debugPrint(
                "❌ Pusher conversation error: $message, code: $code, error: $error");
          },
          // معالج الأحداث العامة - مهم جداً لاستقبال جميع الأحداث
          onEvent: _handleGlobalEvent,
          onSubscriptionSucceeded: (channelName, data) {
            debugPrint("✅ Subscription succeeded: $channelName");
            debugPrint("📊 Channel data: $data");
            _subscribedChannels.add(channelName);
          },
          onSubscriptionError: (message, error) {
            debugPrint("❌ Subscription error: $message");
            debugPrint("📊 Error details: $error");
          },
          onAuthorizer: onAuthorizer);

      // الاتصال بعد التهيئة
      await _pusher.connect();
      _isInitialized = true;

      debugPrint("✅ ConversationPusher: Initialized and connected successfully");
      debugPrint(
          "📊 Stream has listeners: ${conversationStreamController.hasListener}");
    } catch (e) {
      debugPrint("❌ ConversationPusher: Failed to initialize: $e");
      _isInitialized = false;
      rethrow;
    }
  }

  dynamic onAuthorizer(
      String channelName, String socketId, dynamic options) async {
    debugPrint("🔐 Using standard authorizer for channel: $channelName");

    final token = await SecureSharedPrefHelper.getString('userToken');
    var authUrl = '${ApiConstances.baseUrl}/broadcasting/auth';

    var result = await Dio().post(
      authUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
      data: 'socket_id=$socketId&channel_name=$channelName',
    );

    // التأكد أن البيانات في صيغة Map
    var data = result.data is String ? jsonDecode(result.data) : result.data;

    // إذا shared_secret غير موجود نضيفه
    if (!data.containsKey('shared_secret')) {
      data['shared_secret'] = '';
      debugPrint("ℹ️ Added missing shared_secret field to authorizer response");
    }

    return data;
  }

  // معالج الأحداث العامة - المعالج الرئيسي
  void _handleGlobalEvent(PusherEvent event) {
    debugPrint("🌐 Global Event Received:");
    debugPrint("   📺 Channel: ${event.channelName}");
    debugPrint("   🎯 Event Name: ${event.eventName}");
    debugPrint("   📄 Data: ${event.data}");
    debugPrint("   👤 User ID: ${event.userId}");

    try {
      // معالجة أسماء الأحداث المختلفة للمحادثات
      if (_isConversationEvent(event.eventName)) {
        _processConversationEvent(event);
      } else {
        debugPrint("ℹ️ Ignoring non-conversation event: ${event.eventName}");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error processing global event: $e");
      debugPrint("📊 Stack trace: $stackTrace");
    }
  }

  // فحص ما إذا كان الحدث متعلق بالمحادثات
  bool _isConversationEvent(String eventName) {
    final conversationEvents = [
      // أحداث الرسائل الجديدة
      'App\\Events\\PrivateMessageSent',
      'PrivateMessageSent',
      'message.sent',
      'MessageSent',
      'private-message-sent',
      'App\\Events\\MessageSent',
      
      // أحداث المحادثات
      'App\\Events\\ConversationUpdated',
      'ConversationUpdated',
      'conversation.updated',
      'conversation-updated',
      
      // أحداث جديدة للمحادثات
      'App\\Events\\NewConversation',
      'NewConversation',
      'conversation.created',
      'new-conversation',
      
      // أضف المزيد من أسماء الأحداث حسب تكوين Laravel
    ];

    final isConversationEvent = conversationEvents.contains(eventName);
    debugPrint("🔍 Event '$eventName' is conversation event: $isConversationEvent");
    return isConversationEvent;
  }

  // معالجة حدث المحادثة
  void _processConversationEvent(PusherEvent event) {
    try {
      debugPrint("💬 Processing conversation event...");

      // تحليل البيانات
      Map<String, dynamic> eventData;
      if (event.data is String) {
        eventData = jsonDecode(event.data);
      } else if (event.data is Map) {
        eventData = Map<String, dynamic>.from(event.data);
      } else {
        debugPrint("⚠️ Unknown data type: ${event.data.runtimeType}");
        return;
      }

      debugPrint("📊 Parsed event data: $eventData");

      // البحث عن بيانات المحادثة في مستويات مختلفة
      Map<String, dynamic>? conversationData = _extractConversationData(eventData);

      if (conversationData != null) {
        debugPrint("💬 Conversation data extracted successfully");
        debugPrint("📊 Conversation ID: ${conversationData['id']}");
        debugPrint("📊 Participant: ${conversationData['last_message']?['sender']?['name'] ?? 'Unknown'}");

        final conversation = ConversationModel.fromJson(conversationData);

        // التحقق من صحة المحادثة
        if (_isValidConversation(conversation)) {
          conversationStreamController.add(conversation);
          debugPrint("✅ Conversation added to stream: ID ${conversation.id}");
          debugPrint("📊 Participant: ${conversation.participant.name}");
          debugPrint("📊 Last message: ${conversation.lastMessage?.content ?? 'No message'}");
          debugPrint(
              "📊 Stream has listeners: ${conversationStreamController.hasListener}");
          debugPrint(
              "📊 Current stream controller state: ${conversationStreamController.isClosed ? 'Closed' : 'Open'}");
        } else {
          debugPrint("⚠️ Invalid conversation data, skipping");
        }
      } else {
        debugPrint("❌ Could not extract conversation data from event");
        debugPrint(
            "📊 Available keys in eventData: ${eventData.keys.toList()}");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error processing conversation event: $e");
      debugPrint("📊 Stack trace: $stackTrace");
    }
  }

  // استخراج بيانات المحادثة من مستويات مختلفة
  Map<String, dynamic>? _extractConversationData(Map<String, dynamic> eventData) {
    // المحاولة الأولى: البحث عن مفتاح 'conversation'
    if (eventData.containsKey('conversation')) {
      return Map<String, dynamic>.from(eventData['conversation']);
    }

    // المحاولة الثانية: البحث في 'data.conversation'
    if (eventData.containsKey('data')) {
      final data = eventData['data'];
      if (data is Map && data.containsKey('conversation')) {
        return Map<String, dynamic>.from(data['conversation']);
      }
      // إذا كانت 'data' هي المحادثة مباشرة
      if (data is Map && data.containsKey('id') && data.containsKey('participant')) {
        return Map<String, dynamic>.from(data);
      }
    }

    // المحاولة الثالثة: البيانات كاملة هي المحادثة
    if (eventData.containsKey('id') && eventData.containsKey('participant')) {
      return eventData;
    }

    // المحاولة الرابعة: البحث عن مفتاح 'message' والذي قد يحتوي على معلومات المحادثة
    if (eventData.containsKey('message')) {
      final messageData = eventData['message'];
      if (messageData is Map) {
        // إنشاء محادثة من بيانات الرسالة
        return _createConversationFromMessage(Map<String, dynamic>.from(messageData));
      }
    }

    debugPrint("🔍 Could not find conversation data in any expected location");
    return null;
  }

  // إنشاء بيانات محادثة من بيانات الرسالة (في حالة عدم وجود بيانات محادثة مباشرة)
  Map<String, dynamic>? _createConversationFromMessage(Map<String, dynamic> messageData) {
    try {
      // التحقق من وجود بيانات المرسل
      if (!messageData.containsKey('sender')) {
        debugPrint("⚠️ Message data doesn't contain sender information");
        return null;
      }

      final senderData = messageData['sender'];
      if (senderData is! Map) {
        debugPrint("⚠️ Sender data is not in correct format");
        return null;
      }

      // إنشاء محادثة مؤقتة من بيانات الرسالة
      return {
        'id': messageData['conversation_id'] ?? 0, // إذا كان متوفر
        'participant': {
          'id': senderData['id'],
          'name': senderData['name'],
          'profile_picture_url': senderData['profile_picture_url'],
        },
        'last_message': messageData,
        'updated_at': messageData['created_at'] ?? DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint("❌ Error creating conversation from message: $e");
      return null;
    }
  }

  // التحقق من صحة المحادثة
  bool _isValidConversation(ConversationModel conversation) {
    return conversation.id > 0 && conversation.participant.name.isNotEmpty;
  }

  // التحقق من حالة الاتصال
  bool get isConnected {
    final state = _pusher.connectionState.toLowerCase();
    return state == "connected";
  }

  // الحصول على القنوات المشترك بها
  Set<String> get subscribedChannels => Set.unmodifiable(_subscribedChannels);

  // فحص الاشتراك في قناة معينة
  bool isSubscribedTo(int userId) {
    return _subscribedChannels.contains('private-App.Models.User.$userId');
  }

  // الاشتراك في قناة المستخدم لاستقبال المحادثات
  Future<void> subscribeToUserConversations(int userId) async {
    final channelName = 'private-App.Models.User.$userId';

    // التحقق من الاشتراك المسبق
    if (_subscribedChannels.contains(channelName)) {
      debugPrint("ℹ️ Already subscribed to channel: $channelName");
      return;
    }

    try {
      debugPrint("🔄 Subscribing to user conversations channel: $channelName");

      await _pusher.subscribe(
        channelName: channelName,
        onEvent: (event) {
          debugPrint("📨 Channel-specific event received:");
          debugPrint("   📺 Channel: ${event.channelName}");
          debugPrint("   🎯 Event: ${event.eventName}");

          // معالجة الحدث (سيتم معالجته أيضاً في _handleGlobalEvent)
          _handleGlobalEvent(event);
        },
      );

      _subscribedChannels.add(channelName);
      debugPrint("✅ Successfully subscribed to user conversations: $channelName");
      debugPrint("📊 Total subscribed channels: ${_subscribedChannels.length}");
    } catch (e) {
      debugPrint("❌ Error subscribing to channel $channelName: $e");

      // التعامل مع خطأ الاشتراك المتكرر
      if (e.toString().toLowerCase().contains('already subscribed')) {
        _subscribedChannels.add(channelName);
        debugPrint("ℹ️ Channel was already subscribed, added to tracking");
      } else {
        rethrow;
      }
    }
  }

  // الاشتراك في قناة محادثة محددة (اختياري)
  Future<void> subscribeToSpecificConversation(int conversationId) async {
    final channelName = 'private-conversation.$conversationId';

    // التحقق من الاشتراك المسبق
    if (_subscribedChannels.contains(channelName)) {
      debugPrint("ℹ️ Already subscribed to conversation: $channelName");
      return;
    }

    try {
      debugPrint("🔄 Subscribing to specific conversation: $channelName");

      await _pusher.subscribe(
        channelName: channelName,
        onEvent: (event) {
          debugPrint("📨 Conversation-specific event received:");
          debugPrint("   📺 Channel: ${event.channelName}");
          debugPrint("   🎯 Event: ${event.eventName}");

          _handleGlobalEvent(event);
        },
      );

      _subscribedChannels.add(channelName);
      debugPrint("✅ Successfully subscribed to conversation: $channelName");
    } catch (e) {
      debugPrint("❌ Error subscribing to conversation $channelName: $e");
      
      if (e.toString().toLowerCase().contains('already subscribed')) {
        _subscribedChannels.add(channelName);
        debugPrint("ℹ️ Conversation was already subscribed, added to tracking");
      } else {
        rethrow;
      }
    }
  }

  // إلغاء الاشتراك من قناة المستخدم
  Future<void> unsubscribeFromUserConversations(int userId) async {
    final channelName = 'private-App.Models.User.$userId';

    if (!_subscribedChannels.contains(channelName)) {
      debugPrint("ℹ️ Not subscribed to channel: $channelName");
      return;
    }

    try {
      await _pusher.unsubscribe(channelName: channelName);
      _subscribedChannels.remove(channelName);
      debugPrint("✅ Successfully unsubscribed from user conversations: $channelName");
    } catch (e) {
      debugPrint("❌ Error unsubscribing from $channelName: $e");
      // إزالة من المجموعة حتى لو فشل إلغاء الاشتراك
      _subscribedChannels.remove(channelName);
    }
  }

  // إلغاء الاشتراك من محادثة محددة
  Future<void> unsubscribeFromSpecificConversation(int conversationId) async {
    final channelName = 'private-conversation.$conversationId';

    if (!_subscribedChannels.contains(channelName)) {
      debugPrint("ℹ️ Not subscribed to conversation: $channelName");
      return;
    }

    try {
      await _pusher.unsubscribe(channelName: channelName);
      _subscribedChannels.remove(channelName);
      debugPrint("✅ Successfully unsubscribed from conversation: $channelName");
    } catch (e) {
      debugPrint("❌ Error unsubscribing from conversation $channelName: $e");
      _subscribedChannels.remove(channelName);
    }
  }

  // إعادة الاتصال في حالة الانقطاع
  Future<void> reconnect() async {
    try {
      if (!isConnected) {
        debugPrint("🔄 Attempting to reconnect Pusher...");
        await _pusher.connect();
      } else {
        debugPrint("ℹ️ Pusher already connected");
      }
    } catch (e) {
      debugPrint("❌ Failed to reconnect: $e");
    }
  }

  // قطع الاتصال والتنظيف
  Future<void> disconnect() async {
    try {
      debugPrint("🔄 Disconnecting ConversationPusher...");

      // إلغاء جميع الاشتراكات
      final channelsToUnsubscribe = List<String>.from(_subscribedChannels);
      for (String channel in channelsToUnsubscribe) {
        try {
          await _pusher.unsubscribe(channelName: channel);
        } catch (e) {
          debugPrint("❌ Error unsubscribing from $channel: $e");
        }
      }
      _subscribedChannels.clear();

      await _pusher.disconnect();
      _isInitialized = false;

      debugPrint("✅ ConversationPusher disconnected and cleaned up");
    } catch (e) {
      debugPrint("❌ Error disconnecting Pusher: $e");
    }
  }

  // تنظيف الموارد
  void dispose() {
    debugPrint("🗑️ Disposing ConversationPusher...");
    disconnect();
    if (!conversationStreamController.isClosed) {
      conversationStreamController.close();
    }
    debugPrint("✅ ConversationPusher disposed");
  }

  // دالة اختبار شاملة
  Future<void> testConnection() async {
    debugPrint("🧪 ConversationPusher Connection Test:");
    debugPrint("   🔌 Initialized: $_isInitialized");
    debugPrint("   🔌 Connected: $isConnected");
    debugPrint("   📺 Subscribed channels: $_subscribedChannels");
    debugPrint(
        "   👂 Stream has listeners: ${conversationStreamController.hasListener}");
    debugPrint("   🔓 Stream is closed: ${conversationStreamController.isClosed}");
    debugPrint("   📊 Connection state: ${_pusher.connectionState}");
  }

  // دالة لإرسال محادثة اختبار (للتطوير فقط)
  // void sendTestConversation() {
  //   if (!conversationStreamController.isClosed) {
  //     final testConversation = ConversationModel(
  //       id: DateTime.now().millisecondsSinceEpoch,
  //       participant: UserMessage(
  //         id: 999,
  //         name: "Test User",
  //         profilePictureUrl: null,
  //       ),
  //       lastMessage: null, // يمكن إضافة رسالة اختبار هنا
  //       updatedAt: DateTime.now(),
  //     );

  //     conversationStreamController.add(testConversation);
  //     debugPrint("🧪 Test conversation sent to stream");
  //   }
  // }
}