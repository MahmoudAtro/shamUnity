import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/comment/api_comment.dart';
import 'package:shamunity/logic/cubit/comment_state.dart';
import 'package:shamunity/models/comment.dart';

class CommentCubit extends Cubit<CommentState> {
  final ApiComment apiComment;
  List<Comment> comments = [];

  CommentCubit(this.apiComment) : super(CommentInitial());

  Future<void> fetchComments(int postId) async {
    emit(CommentLoading());
    final result = await apiComment.getComments(postId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (listComments) {
        comments = listComments;
        emit(CommentsLoaded(listComments));
      },
    );
  }

  Future<void> addComment(int postId, String content) async {
    emit(CommentLoading());
    final result = await apiComment.addComment(postId, content);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (newComment) {
        comments.insert(0, newComment);
        emit(CommentsLoaded(comments));
      },
    );
  }

  Future<void> deleteComment(int commentId) async {
    emit(CommentLoading());
    final result = await apiComment.deleteComment(commentId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (_) {
        comments.removeWhere((c) => c.id == commentId);
        emit(CommentsLoaded(comments));
      },
    );
  }
}
