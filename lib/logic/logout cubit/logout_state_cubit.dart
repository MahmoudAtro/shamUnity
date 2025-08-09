part of 'logout_cubit.dart';

sealed class LogoutState {}

final class LogoutInitial extends LogoutState {}

final class LogoutLoading extends LogoutState {}

final class LogoutSuccess extends LogoutState {
  final String message;
  
  LogoutSuccess({required this.message});
}

final class LogoutFailure extends LogoutState {
  final String errorMessage;

  LogoutFailure({required this.errorMessage});
}