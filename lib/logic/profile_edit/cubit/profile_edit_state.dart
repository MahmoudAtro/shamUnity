import 'package:shamunity/models/verify_otp_model.dart';

abstract class ProfileEditState {}

class ProfileEditInitial extends ProfileEditState {}

// حالات تغيير كلمة السر
class PasswordChangeLoading extends ProfileEditState {}

class PasswordChangeSuccess extends ProfileEditState {
  final String message;
  PasswordChangeSuccess(this.message);
}

class PasswordChangeError extends ProfileEditState {
  final String error;
  PasswordChangeError(this.error);
}

// حالات تحديث المعلومات الشخصية
class ProfileUpdateLoading extends ProfileEditState {}

class ProfileUpdateSuccess extends ProfileEditState {
  final UserModel user;
  ProfileUpdateSuccess(this.user);
}

class ProfileUpdateError extends ProfileEditState {
  final String error;
  ProfileUpdateError(this.error);
}

// حالات تحميل بيانات المستخدم
class ProfileLoadingState extends ProfileEditState {}

class ProfileLoadSuccess extends ProfileEditState {
  final UserModel user;
  ProfileLoadSuccess(this.user);
}

class ProfileLoadError extends ProfileEditState {
  final String error;
  ProfileLoadError(this.error);
}
