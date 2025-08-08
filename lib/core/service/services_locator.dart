import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/core/network/dio_factory.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';

final getit = GetIt.instance;
bool isLoggedInUser = false;

class ServicesLocator {
  void init() {
    _register();
  }

  void _register() {
    // api
    getit.registerLazySingleton<AuthApi>(
      () => AuthApi(dio: DioFactory.getDio()),
    );
    // bloc
    getit.registerLazySingleton<RegisterBloc>(() => RegisterBloc(getit()));
  }
}

class SingleInstanceService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;
}
