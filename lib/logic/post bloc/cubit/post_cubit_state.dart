import 'package:shamunity/models/notification_model.dart';
import 'package:shamunity/models/post.dart';

abstract class PostCubitState {}

final class PostCubitInitial extends PostCubitState {}

final class PostCubitLoading extends PostCubitState {}

final class PostCubitLoaded extends PostCubitState {
  final List<Post> posts;
  PostCubitLoaded(this.posts);
}

final class PostCubitSuccess extends PostCubitState {
  PostCubitSuccess();
}

final class PostCubitError extends PostCubitState {
  final String message;
  PostCubitError(this.message);
}
// ================================================================

final class PostDeletedSuccess extends PostCubitState {}

final class PostDeletedError extends PostCubitState {
  final String message;
  PostDeletedError(this.message);
}

final class PostDeleteLoading extends PostCubitState {
  final String message;
  PostDeleteLoading(this.message);
}

///======================================================================
final class PostUpdatedLoading extends PostCubitState {}

final class PostUpdatedSuccess extends PostCubitState {}

final class PostUpdatedError extends PostCubitState {
  final String message;
  PostUpdatedError(this.message);
}

//==============================================
final class PostCreatedLoading extends PostCubitState {}

final class PostCreatedSuccess extends PostCubitState {}

final class PostCreatedError extends PostCubitState {
  final String message;
  PostCreatedError(this.message);
}

//=============================================================
final class UserPostsError extends PostCubitState {
  final String message;
  UserPostsError(this.message);
}

final class UserPostsLoaded extends PostCubitState {
  final List<Post> posts;
  UserPostsLoaded(this.posts);
}

final class UserPostsLoading extends PostCubitState {}

final class PostLikeToggling extends PostCubitState {}

final class PostLikeToggled extends PostCubitState {}

final class PostLikeToggleError extends PostCubitState {
  final String message;
  PostLikeToggleError(this.message);
}

class PostDetailLoaded extends PostCubitState {
  final Post post;

  PostDetailLoaded({required this.post});
}

class PostDetailError extends PostCubitState {
  final String message;

  PostDetailError(this.message);
}
