part of 'register_bloc.dart';

sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterFailure extends RegisterState {
  final String message;

  RegisterFailure({required this.message});
}

final class RegisterSuccess extends RegisterState {
  final SignupResponse signupResponse;

  RegisterSuccess({required this.signupResponse});
}
