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

  Future<int> toggleLike(int postId) async {
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
      return response.data['likes_count'] as int;
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
