import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/login_model.dart';
import 'package:shamunity/models/signup_model.dart';
import 'package:shamunity/models/verify_otp_model.dart';

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
        options: Options(),
        data: formData,
      );
      // Check if response indicates failure
      if (response.data['status'] == false) {
        return left(ServerFailure(
            message: response.data['message'] ?? 'Registration failed'));
      }
      final responseData = SignupResponse.fromJson(response.data);
      return Right(responseData);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, VerifyOtpResponse>> login(
      LoginRequest loginRequest) async {
    try {
      var response = await _dio.post(
        ApiConstances.loginUrl,
        options: Options(),
        data: loginRequest.toJson(),
      );
      await SecureSharedPrefHelper.setData(
          "userToken", response.data['token'].toString());
      await SecureSharedPrefHelper.saveUser(
          UserModel.fromJson(response.data['user']));
      final responseData = VerifyOtpResponse.fromJson(response.data);
      return Right(responseData);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, VerifyOtpResponse>> verifyOtp(
      VerifyOtpRequest verification) async {
    try {
      var response = await _dio.post(
        ApiConstances.verifyOtpUrl,
        options: Options(),
        data: verification.toJson(),
      );
      await SecureSharedPrefHelper.setData(
          "userToken", response.data['token'].toString());
      await SecureSharedPrefHelper.saveUser(
          UserModel.fromJson(response.data['user']));
      final responseData = VerifyOtpResponse.fromJson(response.data);
      return Right(responseData);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, ResendOtpResponse>> resendOtp(
      ResendOtpRequest resendOtp) async {
    try {
      var response = await _dio.post(
        ApiConstances.resendOtpUrl,
        options: Options(),
        data: resendOtp.toJson(),
      );

      final responseData = ResendOtpResponse.fromJson(response.data);
      return Right(responseData);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> logout() async {
    try {
      var response = await _dio.post(
        ApiConstances.logoutUrl,
        options: Options(
          headers: {
            "Authorization":
                "Bearer ${await SecureSharedPrefHelper.getString("userToken")}"
          },
        ),
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
