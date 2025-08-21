import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/user_profile/api_visited_user_profile.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_state.dart';

class VisitedUserProfileCubit extends Cubit<VisitedUserProfileState> {
  final ApiVisitedUserProfile _apiVisitedUserProfile;

  VisitedUserProfileCubit(this._apiVisitedUserProfile)
      : super(VisitedUserProfileInitial());

  Future<void> getVisitedUserProfile(int userId) async {
    emit(VisitedUserProfileLoading());

    try {
      final result = await _apiVisitedUserProfile.getVisitedUserProfile(userId);
      debugPrint("result: $result");

      result.fold(
        (failure) => emit(VisitedUserProfileError(failure.message)),
        (profile) => emit(VisitedUserProfileLoaded(profile)),
      );
    } catch (e) {
      emit(VisitedUserProfileError("حدث خطأ غير متوقع: $e"));
    }
  }
}
