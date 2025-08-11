part of 'register_bloc.dart';

sealed class RegisterEvent {}

final class RegisterRequestEvent extends RegisterEvent {
  final File? image;

  RegisterRequestEvent({required this.image});
}
