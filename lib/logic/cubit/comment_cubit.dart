import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/comment/api_comment.dart';
import 'package:shamunity/apis/post/api_post.dart';
import 'package:shamunity/logic/cubit/comment_state.dart';
import 'package:shamunity/models/comment.dart';

class CommentCubit extends Cubit<CommentState> {
  final ApiComment apiComment;
  final PusherService _pusherService = PusherService();
  List<Comment> comments = [];
  StreamSubscription<Map<String, dynamic>>? _commentSubscription;

  CommentCubit(this.apiComment) : super(CommentInitial()) {
    _listenToCommentUpdates();
  }

  void _listenToCommentUpdates() {
    _commentSubscription = _pusherService.commentStream.listen((commentData) {
      if (!isClosed) {
        _handleCommentUpdate(commentData);
      }
    });
  }

  void _handleCommentUpdate(Map<String, dynamic> commentData) {
    final type = commentData['type'] as String;
    // final postId = commentData['postId'] as int;

    switch (type) {
      case 'created':
        final newComment = Comment.fromJson(commentData['comment']);
        comments.insert(0, newComment);
        if (!isClosed) {
          emit(CommentsLoaded(comments));
        }
        break;
      case 'deleted':
        final commentId = commentData['commentId'] as int;
        comments.removeWhere((c) => c.id == commentId);
        if (!isClosed) {
          emit(CommentsLoaded(comments));
        }
        break;
    }
  }

  Future<void> fetchComments(int postId) async {
    if (!isClosed) {
      emit(CommentLoading());
    }

    final result = await apiComment.getComments(postId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (listComments) {
        comments = listComments;
        if (!isClosed) {
          emit(CommentsLoaded(listComments));
        }
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

  @override
  Future<void> close() {
    _commentSubscription?.cancel();
    return super.close();
  }
}
