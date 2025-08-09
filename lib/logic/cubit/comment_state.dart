import 'package:shamunity/models/comment.dart';

class CommentState {
  const CommentState();
}

final class CommentInitial extends CommentState {}

final class CommentLoading extends CommentState {}

final class CommentsLoaded extends CommentState {
  final List<Comment> comments;

  const CommentsLoaded(this.comments);
}

final class CommentAdded extends CommentState {}

final class CommentDeleted extends CommentState {}

final class CommentError extends CommentState {
  final String failure;

  const CommentError(this.failure);
}
