import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/post.dart';

class ApiSearch {
  final Dio _dio;

  ApiSearch({required Dio dio}) : _dio = dio;

  Future<Either<Failure, List<Author>>> searchUsers(String query) async {
    try {
      final response = await _dio.get(
        '${ApiConstances.searchUrl}/$query',
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );

      final List<Author> users = (response.data['data'] as List)
          .map((json) => Author.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(users);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }
}
