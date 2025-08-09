part of 'verification_bloc.dart';

sealed class VerificationState {}

final class VerificationInitial extends VerificationState {}

final class VerificationLoading extends VerificationState {}

final class VerificationFailure extends VerificationState {
  final String message;

  VerificationFailure({required this.message});
}

final class VerificationSuccess extends VerificationState {
  final String message;

  VerificationSuccess({required this.message});
}

final class ResendCodeLoading extends VerificationState {}

final class ResendCodeFailure extends VerificationState {
  final String message;

  ResendCodeFailure({required this.message});
}

final class ResendCodeSuccess extends VerificationState {
  final String message;

  ResendCodeSuccess({required this.message});
}