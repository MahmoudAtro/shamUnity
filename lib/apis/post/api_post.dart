import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/post.dart';

class ApiPost {
  final Dio _dio;
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  ApiPost({required Dio dio}) : _dio = dio;

  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      final response = await _dio.get(
        ApiConstances.postsUrl,
      );
      final List<Post> posts = (response.data['data'] as List)
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(posts);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Post>> createPost(String content, File? image) async {
    try {
      MultipartFile? imageFile;
      if (image != null) {
        imageFile = await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        );
      }
      debugPrint("image: $image");
      FormData formData =
          FormData.fromMap({"content": content, "image": imageFile});
      final response = await _dio.post(
        ApiConstances.postsUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );
      debugPrint("response: ${response.data}");
      return Right(Post.fromJson(response.data['data']));
    } catch (e) {
      if (e is DioException) {
        debugPrint("ErrorDio: ${e.message}");
        return left(ServerFailure.fromDioError(e));
      }
      debugPrint("Error: $e");
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Post>> updatePost(int postId, Post post) async {
    try {
      final response = await _dio.put(
        '${ApiConstances.postsUrl}/$postId',
        data: post.toJson(),
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );
      return Right(Post.fromJson(response.data['data']));
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> deletePost(int postId) async {
    try {
      await _dio.delete(
        '${ApiConstances.postsUrl}/$postId',
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
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Post>>> getUserPosts(int userId) async {
    try {
      final response = await _dio.get(
        ApiConstances.userPosts(userId),
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );
      final List<Post> posts = (response.data['data'] as List)
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(posts);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Post> toggleLike(int postId) async {
    try {
      final response = await _dio.post(
        ApiConstances.addLike(postId),
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );

      // إرجاع المنشور المحدث بالكامل
      return Post.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        throw ServerFailure.fromDioError(e);
      }
      throw ServerFailure(message: e.toString());
    }
  }

  // Alternative implementation without port parameter
  Future<void> listenToNewPostsAlternative(
      void Function(Post) onNewPost) async {
    try {
      // Option 2: Initialize without port parameter
      await _pusher.init(
        apiKey: "acaead266f9e5e8e34c9",
        cluster: "us3",
        // Remove host and port parameters if using standard Pusher setup
        onEvent: (event) {
          debugPrint(
              "Event received: channel=${event.channelName}, event=${event.eventName}, data=${event.data}");

          if (event.channelName == "posts" &&
              event.eventName == "App\\Events\\PostCreated") {
            final Map<String, dynamic> jsonData = jsonDecode(event.data!);
            final post = Post.fromJson(jsonData['post']);
            onNewPost(post);
          }
        },
        onConnectionStateChange: (currentState, previousState) {
          debugPrint(
              "Pusher connection state changed: $previousState -> $currentState");
        },
        onError: (message, code, e) {
          debugPrint("Pusher error: $message");
        },
      );

      await _pusher.subscribe(channelName: "posts");

      debugPrint("Pusher listening to new posts...");
    } catch (e) {
      debugPrint("Pusher Error: $e");
    }
  }

  Future<void> listenToLikeUpdates(
      void Function(int postId, int likesCount) onLikeUpdated) async {
    try {
      await _pusher.init(
        apiKey: "acaead266f9e5e8e34c9",
        cluster: "us3",
        onEvent: (event) {
          if (event.channelName == "post-likes" &&
              event.eventName == "like-updated") {
            final data = jsonDecode(event.data!);
            final postId = data['post_id'] as int;
            final likesCount = data['likes_count'] as int;
            onLikeUpdated(postId, likesCount);
          }
        },
      );

      await _pusher.subscribe(channelName: "post-likes");
    } catch (e) {
      debugPrint("Pusher Error: $e");
    }
  }
}

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  bool _isInitialized = false;

  final _postStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _likeStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _commentStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get postStream => _postStreamController.stream;
  Stream<Map<String, dynamic>> get likeStream => _likeStreamController.stream;
  Stream<Map<String, dynamic>> get commentStream =>
      _commentStreamController.stream;

  Future<void> initPusher() async {
    if (_isInitialized) return;

    try {
      await _pusher.init(
        apiKey: "acaead266f9e5e8e34c9",
        cluster: "us3",
        onEvent: _onEvent,
        onConnectionStateChange: (current, previous) {
          debugPrint("Pusher: $previous → $current");
        },
        onError: (message, code, e) {
          debugPrint("Pusher Error: $message");
        },
      );

      // ✅ اشتراك في القنوات العامة
      await _pusher.subscribe(channelName: "posts");
      await _pusher.subscribe(channelName: "post-likes");

      await _pusher.connect();
      _isInitialized = true;
    } catch (e) {
      debugPrint("Pusher init error: $e");
    }
  }

  // دالة للاشتراك في قناة تعليقات منشور معين
  Future<void> subscribeToPostComments(int postId) async {
    if (!_isInitialized) {
      debugPrint("⚠️ Pusher not initialized, initializing first...");
      await initPusher();
    }

    try {
      final channelName = "post.$postId";
      debugPrint("🔄 Subscribing to comment channel: $channelName");
      await _pusher.subscribe(channelName: channelName);
      debugPrint("✅ Subscribed to comment channel: $channelName");
    } catch (e) {
      debugPrint("❌ Failed to subscribe to comment channel: $e");
    }
  }

  // دالة لإلغاء الاشتراك من قناة تعليقات منشور معين
  Future<void> unsubscribeFromPostComments(int postId) async {
    try {
      final channelName = "post.$postId";
      debugPrint("🔄 Unsubscribing from comment channel: $channelName");
      await _pusher.unsubscribe(channelName: channelName);
      debugPrint("✅ Unsubscribed from comment channel: $channelName");
    } catch (e) {
      debugPrint("❌ Failed to unsubscribe from comment channel: $e");
    }
  }

  void _onEvent(PusherEvent event) {
    debugPrint("📡 Event: ${event.channelName} | ${event.eventName}");
    try {
      final data = event.data is String
          ? jsonDecode(event.data as String)
          : Map<String, dynamic>.from(event.data as Map);

      // التعامل مع القنوات العامة
      if (event.channelName == "posts") {
        _handlePostEvents(event.eventName, data);
      } else if (event.channelName == "post-likes") {
        _handleLikeEvents(event.eventName, data);
      }
      // التعامل مع قنوات التعليقات (post.{post_id})
      else if (event.channelName.startsWith("post.")) {
        _handleCommentEvents(event.eventName, data, event.channelName);
      }
    } catch (e) {
      debugPrint("❌ Error parsing event: $e");
    }
  }

  // 📌 معالجة أحداث المنشورات
  void _handlePostEvents(String eventName, Map<String, dynamic> data) {
    switch (eventName) {
      case "post.created":
        if (data['post'] != null) {
          final post = Post.fromJson(data['post']);
          _postStreamController.add({'action': 'created', 'post': post});
        }
        break;

      case "post.updated":
        if (data['post'] != null) {
          final post = Post.fromJson(data['post']);
          _postStreamController.add({'action': 'updated', 'post': post});
        }
        break;

      case "post.deleted":
        if (data['id'] != null) {
          _postStreamController
              .add({'action': 'deleted', 'postId': data['id']});
        }
        break;
    }
  }

  // 📌 معالجة أحداث الإعجابات
  void _handleLikeEvents(String eventName, Map<String, dynamic> data) {
    if (eventName == "like.updated") {
      _likeStreamController.add({
        'postId': data['post_id'],
        'likesCount': data['likes_count'],
      });
    }
  }

  // 📌 معالجة أحداث التعليقات (مثل api_comment.dart)
  void _handleCommentEvents(
      String eventName, Map<String, dynamic> data, String channelName) {
    // استخراج معرف المنشور من اسم القناة (post.{post_id})
    final postIdMatch = RegExp(r'post\.(\d+)').firstMatch(channelName);
    if (postIdMatch == null) {
      debugPrint(
          "⚠️ Could not extract post_id from channel name: $channelName");
      return;
    }

    final postId = int.parse(postIdMatch.group(1)!);

    switch (eventName) {
      case "comment.posted":
        if (data['comment'] != null) {
          final commentData = data['comment'] is Map
              ? Map<String, dynamic>.from(data['comment'] as Map)
              : data['comment'] as Map<String, dynamic>;

          _commentStreamController.add({
            'type': 'created',
            'postId': postId,
            'comment': commentData,
          });
          debugPrint("✅ Comment posted event sent to stream for post $postId");
        }
        break;

      default:
        debugPrint("📡 Unhandled comment event: $eventName");
        break;
    }
  }

  void dispose() {
    _postStreamController.close();
    _likeStreamController.close();
    _commentStreamController.close();
    _pusher.disconnect();
    _isInitialized = false;
  }
}
