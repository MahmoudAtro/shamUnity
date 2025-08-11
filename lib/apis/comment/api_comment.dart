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
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

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

  Future<void> listenToNewComments(void Function(Comment) onNewComment) async {
    try {
      await _pusher.init(
        apiKey: "acaead266f9e5e8e34c9",
        cluster: "us3",
        onEvent: (event) {
          debugPrint(
              "Event received: channel=${event.channelName}, event=${event.eventName}, data=${event.data}");

          if (event.channelName == "comments" &&
              event.eventName == "App\\Events\\CommentCreated") {
            final Map<String, dynamic> jsonData = jsonDecode(event.data!);
            final comment = Comment.fromJson(jsonData['comment']);
            onNewComment(comment);
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

      await _pusher.subscribe(channelName: "comments");

      debugPrint("Pusher listening to new comments...");
    } catch (e) {
      debugPrint("Pusher Error: $e");
    }
  }
}
