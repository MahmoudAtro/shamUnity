import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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



// class CommentPusherService {
//   static final CommentPusherService _instance = CommentPusherService._internal();
//   factory CommentPusherService() => _instance;
//   CommentPusherService._internal();

//   final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
//   bool _isInitialized = false;

//   final StreamController<Map<String, dynamic>> _commentStreamController =
//       StreamController.broadcast();

//   Stream<Map<String, dynamic>> get commentStream => _commentStreamController.stream;

//   Future<void> initPusher() async {
//     if (_isInitialized) {
//       debugPrint("✅ Comment Pusher already initialized");
//       return;
//     }

//     try {
//       await _pusher.init(
//         apiKey: "acaead266f9e5e8e34c9",
//         cluster: "us3",
//         onConnectionStateChange: (currentState, previousState) {
//           debugPrint("📡 Comment Pusher: $previousState -> $currentState");
//         },
//         onError: (message, code, e) {
//           debugPrint("❌ Comment Pusher Error: $message, code: $code");
//           if (e != null) debugPrint("❌ Exception: $e");
//         },
//         onEvent: _onEvent,
//       );

//       _isInitialized = true;
//       debugPrint("✅ Comment Pusher initialized successfully");
//     } catch (e) {
//       debugPrint("❌ Initialization failed: $e");
//       Future.delayed(const Duration(seconds: 5), () {
//         if (!_isInitialized) {
//           debugPrint("🔄 Retrying Comment Pusher initialization...");
//           initPusher();
//         }
//       });
//     }
//   }

//   Future<void> subscribeToPost(int postId) async {
//     if (!_isInitialized) await initPusher();
//     final channelName = "post.$postId";
//     await _pusher.subscribe(channelName: channelName);
//     debugPrint("✅ Subscribed to comment channel: $channelName");
//   }

//   Future<void> unsubscribeFromPost(int postId) async {
//     final channelName = "post.$postId";
//     await _pusher.unsubscribe(channelName: channelName);
//     debugPrint("✅ Unsubscribed from comment channel: $channelName");
//   }

//   void _onEvent(PusherEvent event) {
//     debugPrint("📡 Comment Event: ${event.channelName} - ${event.eventName}");
//     try {
//       switch (event.eventName) {
//         case "comment.posted":
//           _handleCommentPosted(event);
//           break;
//         case "comment.updated":
//           _handleCommentUpdated(event);
//           break;
//         case "comment.deleted":
//           _handleCommentDeleted(event);
//           break;
//       }
//     } catch (e) {
//       debugPrint("❌ Error handling comment event: $e");
//     }
//   }

//   void _handleCommentPosted(PusherEvent event) {
//     final data = _parseEventData(event);
//     final postId = _extractPostId(event.channelName);
//     if (postId != null && data['comment'] != null) {
//       _commentStreamController.add({
//         'type': 'created',
//         'postId': postId,
//         'comment': data['comment'],
//       });
//     }
//   }

//   void _handleCommentUpdated(PusherEvent event) {
//     final data = _parseEventData(event);
//     final postId = _extractPostId(event.channelName);
//     if (postId != null && data.isNotEmpty) {
//       _commentStreamController.add({
//         'type': 'updated',
//         'postId': postId,
//         'comment': data,
//       });
//     }
//   }

//   void _handleCommentDeleted(PusherEvent event) {
//     final data = _parseEventData(event);
//     final postId = _extractPostId(event.channelName);
//     if (postId != null && data['id'] != null) {
//       _commentStreamController.add({
//         'type': 'deleted',
//         'postId': postId,
//         'commentId': data['id'],
//       });
//     }
//   }

//   Map<String, dynamic> _parseEventData(PusherEvent event) {
//     if (event.data is String) {
//       return jsonDecode(event.data as String);
//     } else if (event.data is Map) {
//       return Map<String, dynamic>.from(event.data as Map);
//     }
//     return {};
//   }

//   int? _extractPostId(String channelName) {
//     final match = RegExp(r'post\.(\d+)').firstMatch(channelName);
//     return match != null ? int.tryParse(match.group(1)!) : null;
//   }

//   void dispose() {
//     _commentStreamController.close();
//     _pusher.disconnect();
//     _isInitialized = false;
//   }
// }


// class CommentPusherService {
//   static final CommentPusherService _instance =
//       CommentPusherService._internal();
//   factory CommentPusherService() => _instance;
//   CommentPusherService._internal();

//   final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
//   bool _isInitialized = false;

//   // Streams للبث
//   final StreamController<Map<String, dynamic>> _commentStreamController =
//       StreamController.broadcast();

//   // Getter للـ Stream
//   Stream<Map<String, dynamic>> get commentStream =>
//       _commentStreamController.stream;

//   Future<void> initPusher() async {
//     if (_isInitialized) {
//       debugPrint("✅ Comment Pusher already initialized");
//       return;
//     }

//     try {
//       debugPrint("🔄 Initializing Comment Pusher...");

//       await _pusher.init(
//         apiKey: "acaead266f9e5e8e34c9",
//         cluster: "us3",
//         onConnectionStateChange: (currentState, previousState) {
//           debugPrint("📡 Comment Pusher: $previousState -> $currentState");
//         },
//         onError: (message, code, e) {
//           debugPrint("❌ Comment Pusher Error: $message, code: $code");
//           if (e != null) {
//             debugPrint("❌ Comment Pusher Exception: $e");
//           }
//         },
//         onEvent: _onEvent,
//       );

//       debugPrint("✅ Comment Pusher initialized successfully");
//       _isInitialized = true;
//       debugPrint("✅ Comment Pusher initialization completed successfully");
//     } catch (e) {
//       debugPrint("❌ Comment Pusher initialization failed: $e");
//       debugPrint("❌ Stack trace: ${StackTrace.current}");
//       _isInitialized = false;
//       // إعادة المحاولة بعد فترة
//       Future.delayed(const Duration(seconds: 5), () {
//         if (!_isInitialized) {
//           debugPrint("🔄 Retrying Comment Pusher initialization...");
//           initPusher();
//         }
//       });
//     }
//   }

//   // دالة للاشتراك في قناة منشور معين
//   Future<void> subscribeToPost(int postId) async {
//     if (!_isInitialized) {
//       debugPrint("⚠️ Comment Pusher not initialized, initializing first...");
//       await initPusher();
//     }

//     try {
//       final channelName = "post.$postId";
//       debugPrint("🔄 Subscribing to comment channel: $channelName");
//       await _pusher.subscribe(channelName: channelName);
//       debugPrint("✅ Subscribed to comment channel: $channelName");
//     } catch (e) {
//       debugPrint("❌ Failed to subscribe to comment channel: $e");
//     }
//   }

//   // دالة لإلغاء الاشتراك من قناة منشور معين
//   Future<void> unsubscribeFromPost(int postId) async {
//     try {
//       final channelName = "post.$postId";
//       debugPrint("🔄 Unsubscribing from comment channel: $channelName");
//       await _pusher.unsubscribe(channelName: channelName);
//       debugPrint("✅ Unsubscribed from comment channel: $channelName");
//     } catch (e) {
//       debugPrint("❌ Failed to unsubscribe from comment channel: $e");
//     }
//   }

//   void _onEvent(PusherEvent event) {
//     debugPrint("📡 Comment Event: ${event.channelName} - ${event.eventName}");

//     try {
//       // التحقق من أن الحدث هو comment.posted
//       if (event.eventName == "comment.posted") {
//         _handleCommentPosted(event);
//       }
//     } catch (e) {
//       debugPrint("❌ Error handling comment event: $e");
//     }
//   }

//   void _handleCommentPosted(PusherEvent event) {
//     try {
//       debugPrint("📡 Raw comment data: ${event.data}");
//       debugPrint("📡 Comment event data type: ${event.data.runtimeType}");

//       // تحويل البيانات إلى النوع الصحيح
//       Map<String, dynamic> data;

//       if (event.data is String) {
//         data = jsonDecode(event.data as String);
//       } else if (event.data is Map) {
//         final rawData = event.data as Map;
//         data = Map<String, dynamic>.from(rawData);
//       } else {
//         debugPrint("❌ Unknown comment data type: ${event.data.runtimeType}");
//         return;
//       }

//       debugPrint("📡 Parsed comment data: $data");

//       // استخراج معرف المنشور من اسم القناة (post.{post_id})
//       final channelName = event.channelName;
//       final postIdMatch = RegExp(r'post\.(\d+)').firstMatch(channelName);

//       if (postIdMatch != null) {
//         final postId = int.parse(postIdMatch.group(1)!);

//         if (data['comment'] != null) {
//           final commentData = data['comment'] is Map
//               ? Map<String, dynamic>.from(data['comment'] as Map)
//               : data['comment'] as Map<String, dynamic>;

//           _commentStreamController.add({
//             'type': 'created',
//             'postId': postId,
//             'comment': commentData,
//           });
//           debugPrint("✅ Comment posted event sent to stream for post $postId");
//         } else {
//           debugPrint("⚠️ No comment data found in comment.posted event");
//         }
//       } else {
//         debugPrint(
//             "⚠️ Could not extract post_id from channel name: $channelName");
//       }
//     } catch (e) {
//       debugPrint("❌ Error parsing comment.posted event: $e");
//       debugPrint("❌ Stack trace: ${StackTrace.current}");
//     }
//   }

//   void dispose() {
//     _commentStreamController.close();
//     _pusher.disconnect();
//     _isInitialized = false;
//   }
// }
