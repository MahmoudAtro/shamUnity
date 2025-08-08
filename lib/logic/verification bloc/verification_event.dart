part of 'verification_bloc.dart';

sealed class VerificationEvent {}

final class VerifyCodeEvent extends VerificationEvent {
  final String email;

  VerifyCodeEvent({required this.email});
}

final class ResendCodeEvent extends VerificationEvent {
  final String email;

  ResendCodeEvent({required this.email});
}