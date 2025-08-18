import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/apis/comment/api_comment.dart';
import 'package:shamunity/apis/post/api_post.dart';
import 'package:shamunity/apis/user_profile/api_search.dart';
import 'package:shamunity/apis/user_profile/api_visited_user_profile.dart';
import 'package:shamunity/core/network/dio_factory.dart';
import 'package:shamunity/apis/library/library_api.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/library%20bloc/library_cubit.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/register bloc/register_bloc.dart';
import 'package:shamunity/logic/search bloc/index.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_cubit.dart';

final getit = GetIt.instance;
bool isLoggedInUser = false;

class ServicesLocator {
  void init() {
    _register();
    _posts();
    _comment();
    _sheikhProfile();
    _search();
    _library();
  }

  void _register() {
    // api
    getit.registerLazySingleton<AuthApi>(
      () => AuthApi(dio: DioFactory.getDio()),
    );
    // bloc
    getit.registerLazySingleton<RegisterBloc>(() => RegisterBloc(getit()));
  }

  void _library() {
    // api
    getit.registerLazySingleton<LibraryApi>(
      () => LibraryApi(dio: DioFactory.getDio()),
    );
    // cubit
    getit.registerFactory<LibraryCubit>(
      () => LibraryCubit(getit()),
    );
  }
}

void _sheikhProfile() {
  // api
  getit.registerLazySingleton<ApiVisitedUserProfile>(
    () => ApiVisitedUserProfile(dio: DioFactory.getDio()),
  );
  // bloc
  getit.registerFactory<VisitedUserProfileCubit>(
      () => VisitedUserProfileCubit(getit()));
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
  // bloc - تغيير إلى Factory لإنشاء نسخة جديدة لكل استخدام
  getit.registerFactory(() => CommentCubit(getit()));
}

void _search() {
  // api
  getit.registerLazySingleton<ApiSearch>(
    () => ApiSearch(dio: DioFactory.getDio()),
  );
  // bloc
  getit.registerFactory(() => SearchCubit(getit()));
}

class SingleInstanceService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;
}
