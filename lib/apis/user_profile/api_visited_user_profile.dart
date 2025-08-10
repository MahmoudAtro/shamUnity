import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/visited_user_profile.dart';

class ApiVisitedUserProfile {
  final Dio _dio;

  ApiVisitedUserProfile({required Dio dio}) : _dio = dio;

  Future<Either<Failure, VisitedUserProfile>> getVisitedUserProfile(
      int userId) async {
    try {
      final response = await _dio.get(
        ApiConstances.userFullProfile(userId),
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );
      print(response.data);
      final visitedUserProfile =
          VisitedUserProfile.fromJson(response.data['data']);
      return Right(visitedUserProfile);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
