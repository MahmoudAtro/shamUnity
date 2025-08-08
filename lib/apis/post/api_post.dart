import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/post.dart';

class ApiPost {
  final Dio _dio;

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

  Future<Either<Failure, Post>> createPost(Post post) async {
    try {
      final response = await _dio.post(
        ApiConstances.postsUrl,
        data: post.toJson(),
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${SecureSharedPrefHelper.getString("token")}',
          },
        ),
      );
      return Right(Post.fromJson(response.data));
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
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
                'Bearer ${SecureSharedPrefHelper.getString("token")}',
          },
        ),
      );
      return Right(Post.fromJson(response.data));
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
                'Bearer Bearer 14|0wRqLresejDSTUzInUby4Xrf9uqT13XJynE5WYpq5d2daeaa',
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

  Future<Either<Failure, List<Post>>> getUserPosts(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiConstances.postsUrl}?user_id=$userId',
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${SecureSharedPrefHelper.getString("token")}',
          },
        ),
      );
      final List<Post> posts = (response.data as List)
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
}
