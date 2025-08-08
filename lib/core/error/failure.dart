import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/theming/styles.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';

abstract class Failure {
  final String message;

  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({required super.message});

  factory ServerFailure.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(message: "connection timout with api server");

      case DioExceptionType.sendTimeout:
        return ServerFailure(message: "send timout with api server");

      case DioExceptionType.receiveTimeout:
        return ServerFailure(message: "receive timout with api server");

      case DioExceptionType.badCertificate:
        return ServerFailure(message: "badCertificate timout with api server");

      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            error.response!.statusCode!, error.response?.data);
      case DioExceptionType.cancel:
        return ServerFailure(message: "request to Api Server was canceld");

      case DioExceptionType.connectionError:
        return ServerFailure(message: "No Internet Connection");

      case DioExceptionType.unknown:
        return ServerFailure(message: "حدثت مشكلة أثناء الاتصال بالخادم");
    }
  }

  factory ServerFailure.fromResponse(int statuscode, dynamic response) {
    BuildContext? context = SingleInstanceService.context;
    String errorMessage = 'Unknown error occurred';

    if (response is Map<String, dynamic>) {
      if (response['message'] is String) {
        errorMessage = response['message'];
      } else {
        errorMessage = response.toString();
      }
    } else if (response is String) {
      errorMessage = response;
    }
    if (statuscode == 404) {
      return ServerFailure(message: errorMessage);
    } else if (statuscode == 500) {
      return ServerFailure(
          message: 'there is a problem with server , please try later');
    } else if (statuscode == 400 || statuscode == 403) {
      // return ServerFailure(message: response['error']['message']);
      return ServerFailure(message: errorMessage);
    } else if (statuscode == 401) {
      return logout(context);
    } else {
      return ServerFailure(message: errorMessage);
    }
  }
}

logout(context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.login,
        color: Colors.red,
        size: 32,
      ),
      content: Text(
        textAlign: TextAlign.center,
        style: TextStyles.font15Regular,
        "انتهت صلاحية الجلسة \n يرجى اعادة تسجيل الدخول",
      ),
      actions: [
        GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Text(
            'الغاء',
            style: isDarkMode
                ? TextStyles.font14Medium
                : TextStyles.font14Medium.copyWith(color: Colors.black),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: () async {
            context.pushNamedAndRemoveUntil("/login",
                predicate: (route) => false);
            await SecureSharedPrefHelper.logout();
          },
          child: Text(
            'تسجيل الدخول',
            style: isDarkMode
                ? TextStyles.font14Medium
                : TextStyles.font14Medium.copyWith(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
