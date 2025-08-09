import 'package:shamunity/models/post.dart';

abstract class PostCubitState {}

final class PostCubitInitial extends PostCubitState {}

final class PostCubitLoading extends PostCubitState {}

final class PostCubitLoaded extends PostCubitState {
  final List<Post> posts;
  PostCubitLoaded(this.posts);
}

final class PostCubitError extends PostCubitState {
  final String message;
  PostCubitError(this.message);
}

final class PostDeletedSuccess extends PostCubitState {}

final class PostDeletedError extends PostCubitState {
  final String message;
  PostDeletedError(this.message);
}

final class PostUpdatedSuccess extends PostCubitState {}

final class PostUpdatedError extends PostCubitState {
  final String message;
  PostUpdatedError(this.message);
}

final class PostCreatedSuccess extends PostCubitState {}
final class PostCreatedLoading extends PostCubitState {}
  

final class UserPostsLoading extends PostCubitState {}

final class UserPostsLoaded extends PostCubitState {
  final List<Post> posts;
  UserPostsLoaded(this.posts);
}
