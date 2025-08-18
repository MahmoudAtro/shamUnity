import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/book_request.dart';
import 'package:shamunity/models/college_model.dart';

class LibraryApi {
  final Dio _dio;

  LibraryApi({required Dio dio}) : _dio = dio;

  // جلب معلومات المكتبة (الكليات والأقسام والسنوات)
  Future<Either<Failure, List<LibraryModel>>> fetchLibraryInfo() async {
    try {
      final response = await _dio.get(
        ApiConstances.libraryUrl,
        options: Options(headers: {
          'Authorization':
              'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
        }),
      );

      if (response.data['success'] == false) {
        return left(ServerFailure(
          message: response.data['message'] ?? 'فشل في جلب معلومات المكتبة',
        ));
      }

      final List<LibraryModel> libraries = (response.data['data'] as List)
          .map((json) => LibraryModel.fromJson(json))
          .toList();

      return Right(libraries);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }

  // رفع كتاب جديد
  Future<Either<Failure, BookRequestResponse>> uploadBook(
    BookRequestModel bookRequest,
  ) async {
    try {
      MultipartFile? file;
      if (bookRequest.file != null) {
        file = await MultipartFile.fromFile(
          bookRequest.file!.path,
          filename: bookRequest.file!.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap({
        'title': bookRequest.title,
        'course_id': bookRequest.courseId,
        if (file != null) 'file': file,
      });

      final response = await _dio.post(
        ApiConstances.bookRequestsUrl,
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization':
              'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
        }),
        data: formData,
      );

      if (response.data['success'] == false) {
        return left(ServerFailure(
          message: response.data['message'] ?? 'فشل في رفع الكتاب',
        ));
      }

      final responseData = BookRequestResponse.fromJson(response.data);
      return Right(responseData);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }
}
