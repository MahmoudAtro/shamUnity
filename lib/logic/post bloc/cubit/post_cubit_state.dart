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
