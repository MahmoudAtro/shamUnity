import 'package:equatable/equatable.dart';
import 'package:shamunity/models/visited_user_profile.dart';

abstract class VisitedUserProfileState extends Equatable {
  const VisitedUserProfileState();

  @override
  List<Object?> get props => [];
}

class VisitedUserProfileInitial extends VisitedUserProfileState {}

class VisitedUserProfileLoading extends VisitedUserProfileState {}

class VisitedUserProfileLoaded extends VisitedUserProfileState {
  final VisitedUserProfile profile;

  const VisitedUserProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class VisitedUserProfileError extends VisitedUserProfileState {
  final String message;

  const VisitedUserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
