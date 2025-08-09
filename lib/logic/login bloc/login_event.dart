part of 'login_bloc.dart';

sealed class LoginEvent {}

final class LoginRequestEvent extends LoginEvent {
  final String email;
  final String password;

  LoginRequestEvent({required this.email, required this.password});
}
