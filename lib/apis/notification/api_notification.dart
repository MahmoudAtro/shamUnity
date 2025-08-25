import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/error/failure.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/models/notification_model.dart';

class ApiNotification {
  final Dio _dio;
  ApiNotification({required Dio dio}) : _dio = dio;

  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _dio.get(
        ApiConstances.notificationsUrl,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization':
                'Bearer ${await SecureSharedPrefHelper.getString("userToken")}',
          },
        ),
      );

      final notificationResponse = (response.data['data'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      debugPrint("✅ Notification Response: $notificationResponse");

      return Right(notificationResponse);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(message: e.toString()));
    }
  }
}
