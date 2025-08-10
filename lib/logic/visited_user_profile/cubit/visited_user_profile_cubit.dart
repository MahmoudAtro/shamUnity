import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/user_profile/api_visited_user_profile.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_state.dart';
import 'package:shamunity/models/visited_user_profile.dart';

class VisitedUserProfileCubit extends Cubit<VisitedUserProfileState> {
  final ApiVisitedUserProfile _apiVisitedUserProfile;
  VisitedUserProfile? visitedUserProfile;

  VisitedUserProfileCubit(this._apiVisitedUserProfile)
      : super(VisitedUserProfileInitial());

  Future<void> getVisitedUserProfile(int userId) async {
    emit(VisitedUserProfileLoading());

    try {
      final result = await _apiVisitedUserProfile.getVisitedUserProfile(userId);

      result.fold(
        (failure) => emit(
            VisitedUserProfileError(failure.message ?? "فشل في جلب البيانات")),
        (profile) {
          visitedUserProfile = profile;
          emit(VisitedUserProfileLoaded(profile));
        },
      );
    } catch (e) {
      emit(VisitedUserProfileError("حدث خطأ غير متوقع: $e"));
    }
  }

  void clearProfile() {
    visitedUserProfile = null;
    emit(VisitedUserProfileInitial());
  }
}
