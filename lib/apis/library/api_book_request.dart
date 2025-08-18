import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/book_request.dart';

class ApiBookRequest {
  final Dio _dio;

  ApiBookRequest({required Dio dio}) : _dio = dio;

  Future<Either<Failure, BookRequestResponse>> createBookRequest(
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

  Future<Either<Failure, List<BookRequestData>>> getBookRequests() async {
    try {
      final response = await _dio.get(ApiConstances.bookRequestsUrl);

      if (response.data['success'] == false) {
        return left(ServerFailure(
          message: response.data['message'] ?? 'فشل في جلب طلبات الكتب',
        ));
      }

      final List<BookRequestData> bookRequests = (response.data['data'] as List)
          .map((json) => BookRequestData.fromJson(json))
          .toList();

      return Right(bookRequests);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }
}
