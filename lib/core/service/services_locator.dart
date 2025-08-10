import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/apis/comment/api_comment.dart';
import 'package:shamunity/apis/post/api_post.dart';
import 'package:shamunity/apis/user_profile/api_visited_user_profile.dart';
import 'package:shamunity/core/network/dio_factory.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_cubit.dart';

final getit = GetIt.instance;
bool isLoggedInUser = false;

class ServicesLocator {
  void init() {
    _register();
    _posts();
    _comment();
    _sheikhProfile();
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

 void _sheikhProfile() {
    // api
    getit.registerLazySingleton<ApiVisitedUserProfile>(
      () => ApiVisitedUserProfile(dio: DioFactory.getDio()),
    );
    // bloc
    getit.registerLazySingleton<VisitedUserProfileCubit>(() => VisitedUserProfileCubit(getit()));
  }




void _posts() {
  // api
  getit.registerLazySingleton<ApiPost>(
    () => ApiPost(dio: DioFactory.getDio()),
  );
  // bloc
  getit.registerLazySingleton(() => PostCubit(getit()));
}

void _comment() {
  // api
  getit.registerLazySingleton<ApiComment>(
    () => ApiComment(dio: DioFactory.getDio()),
  );
  // bloc
  getit.registerLazySingleton(() => CommentCubit(getit()));
}

class SingleInstanceService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;
}
