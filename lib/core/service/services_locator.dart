import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/apis/chat/chat.dart';
import 'package:shamunity/apis/chat/conversation.dart';
import 'package:shamunity/apis/comment/api_comment.dart';
import 'package:shamunity/apis/post/api_post.dart';
import 'package:shamunity/apis/profile_edit/api_profile_edit.dart';
import 'package:shamunity/apis/suggestion_api.dart';
import 'package:shamunity/apis/user_profile/api_search.dart';
import 'package:shamunity/apis/user_profile/api_visited_user_profile.dart';
import 'package:shamunity/core/network/dio_factory.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/profile_edit/cubit/profile_edit_cubit.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';
import 'package:shamunity/logic/search%20bloc/search_cubit.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_cubit.dart';

final getit = GetIt.instance;
bool isLoggedInUser = false;

class ServicesLocator {
  void init() {
    _register();
    _posts();
    _comment();
    _sheikhProfile();
    _conversation();
    _chats();
    _search();
    _suggestion();
    _profileEdit();
  }

  void _register() {
    // api
    getit.registerLazySingleton<AuthApi>(
      () => AuthApi(dio: DioFactory.getDio()),
    );
    // bloc
    getit.registerLazySingleton<RegisterBloc>(() => RegisterBloc(getit()));
  }

  void _suggestion() {
    getit.registerLazySingleton<SuggestionApi>(
      () => SuggestionApi(dio: DioFactory.getDio()),
    );
  }

  void _profileEdit() {
    // api
    getit.registerLazySingleton<ApiProfileEdit>(
      () => ApiProfileEdit(dio: DioFactory.getDio()),
    );
    // cubit
    getit.registerFactory<ProfileEditCubit>(() => ProfileEditCubit(getit()));
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
    getit.registerFactory<PostCubit>(() => PostCubit(getit()));
  }

  void _comment() {
    // api
    getit.registerLazySingleton<ApiComment>(
      () => ApiComment(dio: DioFactory.getDio()),
    );
    // bloc - تغيير إلى Factory لإنشاء نسخة جديدة لكل استخدام
    getit.registerFactory(() => CommentCubit(getit()));
  }

  void _conversation() {
    getit.registerLazySingleton<Conversation>(
        () => Conversation(dio: DioFactory.getDio()));
    getit.registerLazySingleton<ConversationPusher>(() => ConversationPusher());
  }

  void _chats() {
    getit.registerLazySingleton<Chat>(() => Chat(dio: DioFactory.getDio()));
    // getit.registerLazySingleton<ChatMessagePusher>(() => ChatMessagePusher());
  }

  void _search() {
    // api
    getit.registerLazySingleton<ApiSearch>(
      () => ApiSearch(dio: DioFactory.getDio()),
    );
    // bloc
    getit.registerFactory(() => SearchCubit(getit()));
  }
}

class SingleInstanceService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;
}
