import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/comment.dart';

class ApiComment {
  final Dio _dio;
  ApiComment({required Dio dio}) : _dio = dio;

  // Fetch comments for a specific post
  Future<Either<Failure, List<Comment>>> getComments(int postId) async {
    try {
      final response = await _dio.get(
        ApiConstances.postComments(postId),
      );
      final List<Comment> comments = (response.data['data'] as List)
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(comments);
    } catch (e) {
      if (e is DioException) {
        debugPrint("ErrorDio: ${e.message}");
        return left(ServerFailure.fromDioError(e));
      }
      debugPrint("Error: $e");
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Comment>> addComment(
      int postId, String content) async {
    try {
      final response = await _dio.post(
        ApiConstances.postComments(postId),
        data: {'content': content},
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );
      return Right(Comment.fromJson(response.data['data']));
    } catch (e) {
      if (e is DioException) {
        debugPrint("ErrorDio: ${e.message}");
        return left(ServerFailure.fromDioError(e));
      }
      debugPrint("Error: $e");
      return left(ServerFailure(message: e.toString()));
    }
  }

  // Delete a comment
  Future<Either<Failure, Unit>> deleteComment(int commentId) async {
    try {
      await _dio.delete(
        ApiConstances.commentDetails(commentId),
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );
      return const Right(unit);
    } catch (e) {
      if (e is DioException) {
        debugPrint("ErrorDio: ${e.message}");
        return left(ServerFailure.fromDioError(e));
      }
      debugPrint("Error: $e");
      return left(ServerFailure(message: e.toString()));
    }
  }
}

class CommentPusherService {
  static final CommentPusherService _instance =
      CommentPusherService._internal();
  factory CommentPusherService() => _instance;
  CommentPusherService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  bool _isInitialized = false;

  // Streams للبث
  final StreamController<Map<String, dynamic>> _commentStreamController =
      StreamController.broadcast();

  // Getter للـ Stream
  Stream<Map<String, dynamic>> get commentStream =>
      _commentStreamController.stream;

  Future<void> initPusher() async {
    if (_isInitialized) {
      debugPrint("✅ Comment Pusher already initialized");
      return;
    }

    try {
      debugPrint("🔄 Initializing Comment Pusher...");

      await _pusher.init(
        apiKey: "acaead266f9e5e8e34c9",
        cluster: "us3",
        onConnectionStateChange: (currentState, previousState) {
          debugPrint("📡 Comment Pusher: $previousState -> $currentState");
        },
        onError: (message, code, e) {
          debugPrint("❌ Comment Pusher Error: $message, code: $code");
          if (e != null) {
            debugPrint("❌ Comment Pusher Exception: $e");
          }
        },
        onEvent: _onEvent,
      );

      debugPrint("✅ Comment Pusher initialized, subscribing to channels...");

      // الاشتراك في قناة التعليقات
      await _pusher.subscribe(channelName: "post-comments");
      debugPrint("✅ Subscribed to post-comments channel");

      await _pusher.connect();
      debugPrint("✅ Comment Pusher connected");

      _isInitialized = true;
      debugPrint("✅ Comment Pusher initialization completed successfully");
    } catch (e) {
      debugPrint("❌ Comment Pusher initialization failed: $e");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
      _isInitialized = false;
      // إعادة المحاولة بعد فترة
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isInitialized) {
          debugPrint("🔄 Retrying Comment Pusher initialization...");
          initPusher();
        }
      });
    }
  }

  void _onEvent(PusherEvent event) {
    debugPrint("📡 Comment Event: ${event.channelName} - ${event.eventName}");

    try {
      if (event.channelName == "post-comments") {
        _handleCommentEvents(event);
      }
    } catch (e) {
      debugPrint("❌ Error handling comment event: $e");
    }
  }

  void _handleCommentEvents(PusherEvent event) {
    try {
      debugPrint("📡 Raw comment data: ${event.data}");
      debugPrint("📡 Comment event data type: ${event.data.runtimeType}");
      debugPrint("📡 Comment event name: ${event.eventName}");

      // تحويل البيانات إلى النوع الصحيح
      Map<String, dynamic> data;

      if (event.data is String) {
        data = jsonDecode(event.data as String);
      } else if (event.data is Map) {
        final rawData = event.data as Map;
        data = Map<String, dynamic>.from(rawData);
      } else {
        debugPrint("❌ Unknown comment data type: ${event.data.runtimeType}");
        return;
      }

      debugPrint("📡 Parsed comment data: $data");

      switch (event.eventName) {
        case "comment.created":
        case "App\\Events\\CommentCreated":
        case "CommentCreated":
          if (data['comment'] != null) {
            final commentData = data['comment'] is Map
                ? Map<String, dynamic>.from(data['comment'] as Map)
                : data['comment'] as Map<String, dynamic>;

            final postId =
                data['post_id'] as int? ?? data['postId'] as int? ?? 0;

            if (postId > 0) {
              _commentStreamController.add({
                'type': 'created',
                'postId': postId,
                'comment': commentData,
              });
              debugPrint(
                  "✅ Comment created event sent to stream for post $postId");
            } else {
              debugPrint(
                  "⚠️ Invalid post_id in comment created event: $postId");
            }
          } else {
            debugPrint("⚠️ No comment data found in comment created event");
          }
          break;

        case "comment.updated":
        case "App\\Events\\CommentUpdated":
        case "CommentUpdated":
          if (data['comment'] != null) {
            final commentData = data['comment'] is Map
                ? Map<String, dynamic>.from(data['comment'] as Map)
                : data['comment'] as Map<String, dynamic>;

            final postId =
                data['post_id'] as int? ?? data['postId'] as int? ?? 0;

            if (postId > 0) {
              _commentStreamController.add({
                'type': 'updated',
                'postId': postId,
                'comment': commentData,
              });
              debugPrint(
                  "✅ Comment updated event sent to stream for post $postId");
            }
          }
          break;

        case "comment.deleted":
        case "App\\Events\\CommentDeleted":
        case "CommentDeleted":
          final postId = data['post_id'] as int? ?? data['postId'] as int? ?? 0;
          final commentId =
              data['comment_id'] as int? ?? data['commentId'] as int? ?? 0;

          if (postId > 0 && commentId > 0) {
            _commentStreamController.add({
              'type': 'deleted',
              'postId': postId,
              'commentId': commentId,
            });
            debugPrint(
                "✅ Comment deleted event sent to stream for post $postId, comment $commentId");
          } else {
            debugPrint(
                "⚠️ Invalid post_id or comment_id in comment deleted event: postId=$postId, commentId=$commentId");
          }
          break;

        default:
          debugPrint("📡 Unhandled comment event: ${event.eventName}");
          break;
      }
    } catch (e) {
      debugPrint("❌ Error parsing comment event: $e");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
    }
  }

  void dispose() {
    _commentStreamController.close();
    _pusher.disconnect();
    _isInitialized = false;
  }
}
