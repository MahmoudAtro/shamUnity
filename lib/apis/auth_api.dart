import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/models/signup_model.dart';

class AuthApi {
  final Dio _dio;

  AuthApi({required Dio dio}) : _dio = dio;

  Future<Either<Failure, SignupResponse>> register(
      SignupModelRequest signupRequest) async {
    try {
      MultipartFile? userImage;
      if (signupRequest.image != null) {
        userImage = await MultipartFile.fromFile(
          signupRequest.image!.path,
          filename: signupRequest.image!.path.split('/').last,
        );
      }
      FormData formData = FormData.fromMap({
        "first_name": signupRequest.firstName,
        "last_name": signupRequest.lastName,
        "email": signupRequest.email,
        "password": signupRequest.password,
        "gender": signupRequest.gender,
        "birth_date": signupRequest.birthDay,
        "university_id": signupRequest.universityId,
        "college": signupRequest.collage,
        "major": signupRequest.major,
        "year": signupRequest.year,
        "image": userImage
      });
      var response = await _dio.post(
        ApiConstances.registerUrl,
        options: Options(
          headers: {},
        ),
        data: formData,
      );
      final responseData = SignupResponse.fromJson(response.data);
      return Right(responseData);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }
}
