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

  // Streams للبث - نرسل Map بدلاً من Post مباشرة
  final StreamController<Map<String, dynamic>> _postStreamController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _likeStreamController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _commentStreamController =
      StreamController.broadcast();

  // Getters للـ Streams
  Stream<Map<String, dynamic>> get postStream => _postStreamController.stream;
  Stream<Map<String, dynamic>> get likeStream => _likeStreamController.stream;
  Stream<Map<String, dynamic>> get commentStream =>
      _commentStreamController.stream;

  Future<void> initPusher() async {
    if (_isInitialized) {
      debugPrint("✅ Pusher already initialized");
      return;
    }

    try {
      debugPrint("🔄 Initializing Pusher...");

      await _pusher.init(
        apiKey: "acaead266f9e5e8e34c9",
        cluster: "us3",
        onConnectionStateChange: (currentState, previousState) {
          debugPrint("📡 Pusher: $previousState -> $currentState");
        },
        onError: (message, code, e) {
          debugPrint("❌ Pusher Error: $message, code: $code");
          if (e != null) {
            debugPrint("❌ Pusher Exception: $e");
          }
        },
        onEvent: _onEvent,
      );

      debugPrint("✅ Pusher initialized, subscribing to channels...");

      // الاشتراك في القنوات
      await _pusher.subscribe(channelName: "posts");
      debugPrint("✅ Subscribed to posts channel");

      await _pusher.subscribe(channelName: "post-likes");
      debugPrint("✅ Subscribed to post-likes channel");

      await _pusher.subscribe(channelName: "post-comments");
      debugPrint("✅ Subscribed to post-comments channel");

      await _pusher.connect();
      debugPrint("✅ Pusher connected");

      _isInitialized = true;
      debugPrint("✅ Pusher initialization completed successfully");
    } catch (e) {
      debugPrint("❌ Pusher initialization failed: $e");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
      _isInitialized = false;
      // إعادة المحاولة بعد فترة
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isInitialized) {
          debugPrint("🔄 Retrying Pusher initialization...");
          initPusher();
        }
      });
    }
  }

  void _onEvent(PusherEvent event) {
    debugPrint("📡 Event: ${event.channelName} - ${event.eventName}");

    try {
      switch (event.channelName) {
        case "posts":
          _handlePostEvents(event);
          break;
        case "post-likes":
          _handleLikeEvents(event);
          break;
        case "post-comments":
          _handleCommentEvents(event);
          break;
      }
    } catch (e) {
      debugPrint("❌ Error handling event: $e");
    }
  }

  void _handlePostEvents(PusherEvent event) {
    try {
      debugPrint("📡 Raw event data: ${event.data}");
      debugPrint("📡 Event data type: ${event.data.runtimeType}");
      debugPrint("📡 Event name: ${event.eventName}");
      debugPrint("📡 Channel name: ${event.channelName}");

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
        debugPrint("❌ Unknown data type: ${event.data.runtimeType}");
        return;
      }

      debugPrint("📡 Parsed data: $data");

      switch (event.eventName) {
        case "post.created":
        case "App\\Events\\PostCreated":
        case "PostCreated":
          debugPrint("📡 Handling post.created event");
          if (data['post'] != null) {
            final postData = data['post'] is Map
                ? Map<String, dynamic>.from(data['post'] as Map)
                : data['post'] as Map<String, dynamic>;
            final post = Post.fromJson(postData);
            _postStreamController.add({
              'action': 'created',
              'post': post,
            });
            debugPrint("✅ Post created event sent to stream");
          } else {
            debugPrint("⚠️ No post data found in event");
          }
          break;

        case "post.updated":
        case "App\\Events\\PostUpdated":
        case "PostUpdated":
          debugPrint("📡 Handling post.updated event");
          if (data['post'] != null) {
            final postData = data['post'] is Map
                ? Map<String, dynamic>.from(data['post'] as Map)
                : data['post'] as Map<String, dynamic>;
            final post = Post.fromJson(postData);
            _postStreamController.add({
              'action': 'updated',
              'post': post,
            });
            debugPrint("✅ Post updated event sent to stream");
          }
          break;

        case "post.deleted":
        case "App\\Events\\PostDeleted":
        case "PostDeleted":
          debugPrint("📡 Handling post.deleted event");
          _postStreamController.add({
            'action': 'deleted',
            'postId': data['post_id'] as int? ?? data['id'] as int? ?? 0,
          });
          debugPrint("✅ Post deleted event sent to stream");
          break;

        default:
          debugPrint("📡 Unhandled post event: ${event.eventName}");
          break;
      }
    } catch (e) {
      debugPrint("❌ Error parsing post event: $e");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
    }
  }

  void _handleLikeEvents(PusherEvent event) {
    debugPrint("📡 Like event received: ${event.eventName}");
    debugPrint("📡 Like channel: ${event.channelName}");

    // التعامل مع أنواع مختلفة من like events
    if (event.eventName == "like.updated" ||
        event.eventName == "like.created" ||
        event.eventName == "like.deleted" ||
        event.eventName == "App\\Events\\LikeUpdated" ||
        event.eventName == "App\\Events\\LikeCreated" ||
        event.eventName == "App\\Events\\LikeDeleted" ||
        event.eventName == "LikeUpdated" ||
        event.eventName == "LikeCreated" ||
        event.eventName == "LikeDeleted") {
      try {
        debugPrint("📡 Raw like data: ${event.data}");
        debugPrint("📡 Like event name: ${event.eventName}");

        Map<String, dynamic> data;

        if (event.data is String) {
          data = jsonDecode(event.data as String);
        } else if (event.data is Map) {
          final rawData = event.data as Map;
          data = Map<String, dynamic>.from(rawData);
        } else {
          debugPrint("❌ Unknown like data type: ${event.data.runtimeType}");
          return;
        }

        debugPrint("📡 Parsed like data: $data");

        // محاولة استخراج البيانات من أماكن مختلفة
        final postId = data['post_id'] as int? ??
            data['postId'] as int? ??
            data['id'] as int? ??
            0;
        final likesCount = data['likes_count'] as int? ??
            data['likesCount'] as int? ??
            data['count'] as int? ??
            0;
        final isLiked = data['is_liked'] as bool? ??
            data['isLiked'] as bool? ??
            data['liked'] as bool? ??
            false;

        debugPrint(
            "📡 Extracted - post_id: $postId, likes_count: $likesCount, is_liked: $isLiked");

        if (postId > 0) {
          _likeStreamController.add({
            'postId': postId,
            'likesCount': likesCount,
            'isLiked': isLiked,
          });
          debugPrint("✅ Like event sent to stream");
        } else {
          debugPrint("⚠️ Invalid post_id in like event: $postId");
        }
      } catch (e) {
        debugPrint("❌ Error parsing like event: $e");
      }
    } else {
      debugPrint("📡 Unhandled like event: ${event.eventName}");
    }
  }

  void _handleCommentEvents(PusherEvent event) {
    try {
      debugPrint("📡 Raw comment data: ${event.data}");
      debugPrint("📡 Comment event name: ${event.eventName}");
      debugPrint("📡 Comment channel: ${event.channelName}");

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
    _postStreamController.close();
    _likeStreamController.close();
    _commentStreamController.close();
    _pusher.disconnect();
    _isInitialized = false;
  }
}
