import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/verify_otp_model.dart';

class ApiProfileEdit {
  final Dio _dio;

  ApiProfileEdit({required Dio dio}) : _dio = dio;

  /// تغيير كلمة السر
  Future<Either<Failure, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstances.changePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );

      return Right(response.data['message'] ?? 'تم تغيير كلمة السر بنجاح');
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// تحديث معلومات المستخدم
  Future<Either<Failure, UserModel>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? profilePicturePath,
  }) async {
    try {
      FormData formData = FormData();

      if (firstName != null) {
        formData.fields.add(MapEntry('first_name', firstName));
      }
      if (lastName != null) {
        formData.fields.add(MapEntry('last_name', lastName));
      }
      if (profilePicturePath != null) {
        MultipartFile? imageFile = await MultipartFile.fromFile(
          profilePicturePath,
          filename: profilePicturePath.split('/').last,
        );
        formData.files.add(
          MapEntry(
            'profile_picture',
            imageFile,
          ),
        );
      }

      final response = await _dio.post(
        ApiConstances.updateProfile,
        data: formData,
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final updatedUser = UserModel.fromJson(response.data['data']);

      // تحديث بيانات المستخدم في SharedPreferences
      await SecureSharedPrefHelper.saveUser(updatedUser);

      return Right(updatedUser);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
