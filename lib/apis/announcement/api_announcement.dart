import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/models/announcement.dart';

class ApiAnnouncement {
  final Dio _dio;
  ApiAnnouncement({required Dio dio}) : _dio = dio;

  Future<Either<Failure, List<Announcement>>> getAnnouncements() async {
    try {
      final response = await _dio.get(
        ApiConstances.announcementsUrl,
      );

      final List<dynamic> data = response.data['data'];
      print(data);
      final announcements =
          data.map((json) => Announcement.fromJson(json)).toList();
      return Right(announcements);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }
}

class AnnouncementPusherService {
  static final AnnouncementPusherService _instance =
      AnnouncementPusherService._internal();
  factory AnnouncementPusherService() => _instance;
  AnnouncementPusherService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  bool _isInitialized = false;

  // Streams للبث
  final StreamController<Map<String, dynamic>> _announcementStreamController =
      StreamController.broadcast();

  // Getter للـ Stream
  Stream<Map<String, dynamic>> get announcementStream =>
      _announcementStreamController.stream;

  Future<void> initPusher() async {
    if (_isInitialized) {
      debugPrint("✅ Announcement Pusher already initialized");
      return;
    }

    try {
      debugPrint("🔄 Initializing Announcement Pusher...");

      await _pusher.init(
        apiKey: "acaead266f9e5e8e34c9",
        cluster: "us3",
        onConnectionStateChange: (currentState, previousState) {
          debugPrint("📡 Announcement Pusher: $previousState -> $currentState");
        },
        onError: (message, code, e) {
          debugPrint("❌ Announcement Pusher Error: $message, code: $code");
          if (e != null) {
            debugPrint("❌ Announcement Pusher Exception: $e");
          }
        },
        onEvent: _onEvent,
      );

      debugPrint(
          "✅ Announcement Pusher initialized, subscribing to channels...");

      // الاشتراك في قناة الإعلانات
      await _pusher.subscribe(channelName: "announcements");
      debugPrint("✅ Subscribed to announcements channel");

      await _pusher.connect();
      debugPrint("✅ Announcement Pusher connected");

      _isInitialized = true;
      debugPrint("✅ Announcement Pusher initialization completed successfully");
    } catch (e) {
      debugPrint("❌ Announcement Pusher initialization failed: $e");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
      _isInitialized = false;
      // إعادة المحاولة بعد فترة
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isInitialized) {
          debugPrint("🔄 Retrying Announcement Pusher initialization...");
          initPusher();
        }
      });
    }
  }

  void _onEvent(PusherEvent event) {
    debugPrint(
        "📡 Announcement Event: ${event.channelName} - ${event.eventName}");

    try {
      if (event.channelName == "announcements") {
        _handleAnnouncementEvents(event);
      }
    } catch (e) {
      debugPrint("❌ Error handling announcement event: $e");
    }
  }

  void _handleAnnouncementEvents(PusherEvent event) {
    try {
      debugPrint("📡 Raw announcement event data: ${event.data}");
      debugPrint("📡 Announcement event data type: ${event.data.runtimeType}");
      debugPrint("📡 Announcement event name: ${event.eventName}");

      // تحويل البيانات إلى النوع الصحيح
      Map<String, dynamic> data;

      if (event.data is String) {
        // إذا كانت البيانات JSON string
        data = jsonDecode(event.data as String);
      } else if (event.data is Map) {
        // إذا كانت البيانات Map
        final rawData = event.data as Map;
        data = Map<String, dynamic>.from(rawData);
      } else {
        debugPrint(
            "❌ Unknown announcement data type: ${event.data.runtimeType}");
        return;
      }

      debugPrint("📡 Parsed announcement data: $data");

      switch (event.eventName) {
        case "announcement.created":
        case "App\\Events\\AnnouncementCreated":
        case "AnnouncementCreated":
          debugPrint("📡 Handling announcement.created event");
          if (data['announcement'] != null) {
            final announcementData = data['announcement'] is Map
                ? Map<String, dynamic>.from(data['announcement'] as Map)
                : data['announcement'] as Map<String, dynamic>;
            final announcement = Announcement.fromJson(announcementData);
            _announcementStreamController.add({
              'action': 'created',
              'announcement': announcement,
            });
            debugPrint("✅ Announcement created event sent to stream");
          } else {
            debugPrint("⚠️ No announcement data found in event");
          }
          break;

        case "announcement.updated":
        case "App\\Events\\AnnouncementUpdated":
        case "AnnouncementUpdated":
          debugPrint("📡 Handling announcement.updated event");
          if (data['announcement'] != null) {
            final announcementData = data['announcement'] is Map
                ? Map<String, dynamic>.from(data['announcement'] as Map)
                : data['announcement'] as Map<String, dynamic>;
            final announcement = Announcement.fromJson(announcementData);
            _announcementStreamController.add({
              'action': 'updated',
              'announcement': announcement,
            });
            debugPrint("✅ Announcement updated event sent to stream");
          }
          break;

        case "announcement.deleted":
        case "App\\Events\\AnnouncementDeleted":
        case "AnnouncementDeleted":
          debugPrint("📡 Handling announcement.deleted event");
          _announcementStreamController.add({
            'action': 'deleted',
            'announcementId':
                data['announcement_id'] as int? ?? data['id'] as int? ?? 0,
          });
          debugPrint("✅ Announcement deleted event sent to stream");
          break;

        default:
          debugPrint("📡 Unhandled announcement event: ${event.eventName}");
          break;
      }
    } catch (e) {
      debugPrint("❌ Error parsing announcement event: $e");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
    }
  }

  void dispose() {
    _announcementStreamController.close();
    _pusher.disconnect();
    _isInitialized = false;
  }
}
