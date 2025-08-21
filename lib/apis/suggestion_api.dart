import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/suggestion_model.dart';

class SuggestionApi {
  final Dio _dio;

  SuggestionApi({required Dio dio}) : _dio = dio;

  Future<Either<Failure, String>> sendSuggestion(
      SuggestionModel suggestion) async {
    try {
      var response = await _dio.post(
        ApiConstances.suggestion,
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
        data: suggestion.toJson(),
      );
      return Right(response.data['message']);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }
}
