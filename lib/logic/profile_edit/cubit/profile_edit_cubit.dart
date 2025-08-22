import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/profile_edit/api_profile_edit.dart';
import 'package:shamunity/logic/profile_edit/cubit/profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  final ApiProfileEdit _apiProfileEdit;

  ProfileEditCubit(this._apiProfileEdit) : super(ProfileEditInitial());

  /// تغيير كلمة السر
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(PasswordChangeLoading());

    // التحقق من مطابقة كلمة السر الجديدة
    if (newPassword != confirmPassword) {
      emit(PasswordChangeError('كلمة السر الجديدة غير متطابقة'));
      return;
    }

    // التحقق من قوة كلمة السر
    if (newPassword.length < 8) {
      emit(PasswordChangeError('كلمة السر يجب أن تكون 8 أحرف على الأقل'));
      return;
    }

    final result = await _apiProfileEdit.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) => emit(PasswordChangeError(failure.message)),
      (message) => emit(PasswordChangeSuccess(message)),
    );
  }

  /// تحديث معلومات المستخدم
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? profilePicturePath,
  }) async {
    emit(ProfileUpdateLoading());

    final result = await _apiProfileEdit.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      profilePicturePath: profilePicturePath,
    );

    result.fold(
      (failure) => emit(ProfileUpdateError(failure.message)),
      (user) => emit(ProfileUpdateSuccess(user)),
    );
  }

  /// إعادة تعيين الحالة
  void resetState() {
    emit(ProfileEditInitial());
  }
}
