import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/chat_message_model.dart';

class Chat {
  final Dio _dio;

  Chat({required Dio dio}) : _dio = dio;

  Future<Either<Failure, List<ChatMessageModel>>> getMessages(
      int conversationId) async {
    try {
      final response = await _dio.get(
        ApiConstances.getChatMessages(conversationId),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );
      final List<ChatMessageModel> messages = (response.data['data'] as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
      return Right(messages);
    } catch (e) {
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, ChatMessageModel>> sendMessage(int userId, String type,
      {String? content, File? attachment}) async {
    try {
      MultipartFile? file;
      if (attachment != null) {
        file = await MultipartFile.fromFile(
          attachment.path,
          filename: attachment.path.split('/').last,
        );
      }
      FormData formData = FormData.fromMap(
          {"content": content, "type": type, "attachment": file});
      final response = await _dio.post(ApiConstances.sendMessage(userId),
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'multipart/form-data',
              'Authorization':
                  'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
            },
          ),
          data: formData);
      final ChatMessageModel message =
          ChatMessageModel.fromJson(response.data['message']);
      return Right(message);
    } catch (e) {
      if (e is DioException) return left(ServerFailure.fromDioError(e));
      return left(ServerFailure(message: e.toString()));
    }
  }
}

class ChatMessagePusher {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final messageStreamController =
      StreamController<ChatMessageModel>.broadcast();

  Stream<ChatMessageModel> get messagesStream => messageStreamController.stream;

  // تتبع القنوات المشترك بها لتجنب الاشتراك المتكرر
  final Set<String> _subscribedChannels = <String>{};
  bool _isInitialized = false;

  Future<void> init() async {
    // تجنب إعادة التهيئة إذا كان مُهيأ بالفعل
    if (_isInitialized) {
      debugPrint("✅ ChatMessagePusher: Already initialized");
      return;
    }

    try {
      debugPrint("🔄 ChatMessagePusher: Starting initialization...");

      await _pusher.init(
          apiKey: "acaead266f9e5e8e34c9",
          cluster: "us3",
          useTLS: false,
          onConnectionStateChange: (currentState, previousState) {
            debugPrint(
                "🔄 Pusher connection state changed: $previousState -> $currentState");

            if (currentState == "CONNECTED" || currentState == "connected") {
              debugPrint("✅ Pusher chat connected successfully");
            } else if (currentState == "DISCONNECTED" ||
                currentState == "disconnected") {
              debugPrint("❌ Pusher chat disconnected");
            }
          },
          onError: (message, code, error) {
            debugPrint(
                "❌ Pusher chat error: $message, code: $code, error: $error");
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
          // authEndpoint: "${ApiConstances.baseUrl}/broadcasting/auth",
          onAuthorizer: onAuthorizer);

      // الاتصال بعد التهيئة
      await _pusher.connect();
      _isInitialized = true;

      debugPrint("✅ ChatMessagePusher: Initialized and connected successfully");
      debugPrint(
          "📊 Stream has listeners: ${messageStreamController.hasListener}");
    } catch (e) {
      debugPrint("❌ ChatMessagePusher: Failed to initialize: $e");
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
      // معالجة أسماء الأحداث المختلفة
      if (_isMessageEvent(event.eventName)) {
        _processMessageEvent(event);
      } else {
        debugPrint("ℹ️ Ignoring non-message event: ${event.eventName}");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error processing global event: $e");
      debugPrint("📊 Stack trace: $stackTrace");
    }
  }

  // فحص ما إذا كان الحدث متعلق بالرسائل
  bool _isMessageEvent(String eventName) {
    final messageEvents = [
      'App\\Events\\PrivateMessageSent',
      'PrivateMessageSent',
      'message.sent',
      'MessageSent',
      'private-message-sent',
      'App\\Events\\MessageSent',
      // أضف المزيد من أسماء الأحداث حسب تكوين Laravel
    ];

    final isMessage = messageEvents.contains(eventName);
    debugPrint("🔍 Event '$eventName' is message event: $isMessage");
    return isMessage;
  }

  // معالجة حدث الرسالة
  void _processMessageEvent(PusherEvent event) {
    try {
      debugPrint("📨 Processing message event...");

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

      // البحث عن بيانات الرسالة في مستويات مختلفة
      Map<String, dynamic>? messageData = _extractMessageData(eventData);

      if (messageData != null) {
        debugPrint("💬 Message data extracted successfully");
        debugPrint("📊 Message content: ${messageData['content']}");

        final message = ChatMessageModel.fromJson(messageData);

        // التحقق من صحة الرسالة
        if (_isValidMessage(message)) {
          messageStreamController.add(message);
          debugPrint("✅ Message added to stream: ${message.content}");
          debugPrint(
              "📊 Stream has listeners: ${messageStreamController.hasListener}");
          debugPrint(
              "📊 Current stream controller state: ${messageStreamController.isClosed ? 'Closed' : 'Open'}");
        } else {
          debugPrint("⚠️ Invalid message data, skipping");
        }
      } else {
        debugPrint("❌ Could not extract message data from event");
        debugPrint(
            "📊 Available keys in eventData: ${eventData.keys.toList()}");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error processing message event: $e");
      debugPrint("📊 Stack trace: $stackTrace");
    }
  }

  // استخراج بيانات الرسالة من مستويات مختلفة
  Map<String, dynamic>? _extractMessageData(Map<String, dynamic> eventData) {
    // المحاولة الأولى: البحث عن مفتاح 'message'
    if (eventData.containsKey('message')) {
      return Map<String, dynamic>.from(eventData['message']);
    }

    // المحاولة الثانية: البحث في 'data.message'
    if (eventData.containsKey('data')) {
      final data = eventData['data'];
      if (data is Map && data.containsKey('message')) {
        return Map<String, dynamic>.from(data['message']);
      }
      // إذا كانت 'data' هي الرسالة مباشرة
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    }

    // المحاولة الثالثة: البيانات كاملة هي الرسالة
    if (eventData.containsKey('id') && eventData.containsKey('content')) {
      return eventData;
    }

    debugPrint("🔍 Could not find message data in any expected location");
    return null;
  }

  // التحقق من صحة الرسالة
  bool _isValidMessage(ChatMessageModel messageData) {
  // التحقق من نوع الرسالة
  final messageType = messageData.type;
  
  if (messageType == 'text') {
    // رسائل النص تحتاج content
    if (messageData.content.toString().trim().isEmpty) {
      debugPrint("! رسالة نصية بدون محتوى، تم تجاهلها");
      return false;
    }
  } else if (messageType == 'image' || messageType == 'audio' || messageType == 'file') {
    // رسائل الصور تحتاج file_url
    if (messageData.fileUrl== null || messageData.fileUrl.toString().trim().isEmpty) {
      debugPrint("! رسالة صورة بدون رابط الملف، تم تجاهلها");
      return false;
    }
  } else if (messageType == 'file') {
    // رسائل الملفات تحتاج file_url
    if (messageData.fileUrl == null || messageData.fileUrl.toString().trim().isEmpty) {
      debugPrint("! رسالة ملف بدون رابط الملف، تم تجاهلها");
      return false;
    }
  }
  
  return true;
  }

  // التحقق من حالة الاتصال
  bool get isConnected {
    final state = _pusher.connectionState.toLowerCase();
    return state == "connected";
  }

  // الحصول على القنوات المشترك بها
  Set<String> get subscribedChannels => Set.unmodifiable(_subscribedChannels);

  // فحص الاشتراك في قناة معينة
  bool isSubscribedTo(int conversationId) {
    return _subscribedChannels.contains('private-chat.private.$conversationId');
  }

  Future<void> subscribeToConversation(int conversationId) async {
    final channelName = 'private-chat.private.$conversationId';

    // التحقق من الاشتراك المسبق
    if (_subscribedChannels.contains(channelName)) {
      debugPrint("ℹ️ Already subscribed to channel: $channelName");
      return;
    }

    try {
      debugPrint("🔄 Subscribing to channel: $channelName");

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
      debugPrint("✅ Successfully subscribed to channel: $channelName");
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

  // إلغاء الاشتراك من قناة معينة
  Future<void> unsubscribeFromConversation(int conversationId) async {
    final channelName = 'private-chat.private.$conversationId';

    if (!_subscribedChannels.contains(channelName)) {
      debugPrint("ℹ️ Not subscribed to channel: $channelName");
      return;
    }

    try {
      await _pusher.unsubscribe(channelName: channelName);
      _subscribedChannels.remove(channelName);
      debugPrint("✅ Successfully unsubscribed from: $channelName");
    } catch (e) {
      debugPrint("❌ Error unsubscribing from $channelName: $e");
      // إزالة من المجموعة حتى لو فشل إلغاء الاشتراك
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
      debugPrint("🔄 Disconnecting ChatMessagePusher...");

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

      debugPrint("✅ ChatMessagePusher disconnected and cleaned up");
    } catch (e) {
      debugPrint("❌ Error disconnecting Pusher: $e");
    }
  }

  // تنظيف الموارد
  void dispose() {
    debugPrint("🗑️ Disposing ChatMessagePusher...");
    disconnect();
    if (!messageStreamController.isClosed) {
      messageStreamController.close();
    }
    debugPrint("✅ ChatMessagePusher disposed");
  }

  // دالة اختبار شاملة
  Future<void> testConnection() async {
    debugPrint("🧪 ChatMessagePusher Connection Test:");
    debugPrint("   🔌 Initialized: $_isInitialized");
    debugPrint("   🔌 Connected: $isConnected");
    debugPrint("   📺 Subscribed channels: $_subscribedChannels");
    debugPrint(
        "   👂 Stream has listeners: ${messageStreamController.hasListener}");
    debugPrint("   🔓 Stream is closed: ${messageStreamController.isClosed}");
    debugPrint("   📊 Connection state: ${_pusher.connectionState}");
  }

  // دالة لإرسال رسالة اختبار (للتطوير فقط)
  // void sendTestMessage() {
  //   if (!messageStreamController.isClosed) {
  //     final testMessage = ChatMessageModel(
  //       id: DateTime.now().millisecondsSinceEpoch,
  //       content: "🧪 Test message from Pusher - ${DateTime.now().toString().substring(11, 19)}",
  //       type: "text",
  //       createdAt: DateTime.now().toIso8601String(),
  //       sender: MessageSender(id: 999, name: "Test Pusher"),
  //     );

  //     messageStreamController.add(testMessage);
  //     debugPrint("🧪 Test message sent to stream");
  //   }
  // }
}
