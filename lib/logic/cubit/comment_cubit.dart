import 'dart:async';

import 'package:flutter/foundation.dart';
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
  int? _currentPostId; // لتخزين معرف المنشور الحالي

  CommentCubit(this.apiComment) : super(CommentInitial()) {
    debugPrint("🔄 CommentCubit: Creating new instance");
    _initializePusher();
  }

  Future<void> _initializePusher() async {
    try {
      debugPrint("🔄 CommentCubit: Initializing Pusher...");
      await _pusherService.initPusher();
      debugPrint("✅ CommentCubit: Pusher initialized successfully");
      _listenToCommentUpdates();
      debugPrint("✅ CommentCubit: Comment updates listener started");
    } catch (e) {
      debugPrint("❌ CommentCubit: Failed to initialize Pusher: $e");
      // إعادة المحاولة بعد فترة
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) {
          debugPrint("🔄 CommentCubit: Retrying Pusher initialization...");
          _initializePusher();
        }
      });
    }
  }

  void _listenToCommentUpdates() {
    try {
      _commentSubscription = _pusherService.commentStream.listen(
        (commentData) {
          debugPrint("📡 CommentCubit: Received comment update: $commentData");
          if (!isClosed) {
            _handleCommentUpdate(commentData);
          } else {
            debugPrint(
                "⚠️ CommentCubit: Cubit is closed, ignoring comment update");
          }
        },
        onError: (error) {
          debugPrint("❌ CommentCubit: Stream error: $error");
        },
      );
      debugPrint("✅ CommentCubit: Comment stream listener set up successfully");
    } catch (e) {
      debugPrint(
          "❌ CommentCubit: Failed to set up comment stream listener: $e");
    }
  }

  void _handleCommentUpdate(Map<String, dynamic> commentData) {
    try {
      final type = commentData['type'] as String?;
      final postId = commentData['postId'] as int?;

      if (type == null || postId == null) {
        debugPrint(
            "⚠️ CommentCubit: Invalid comment data format: $commentData");
        return;
      }

      debugPrint(
          "🔄 CommentCubit: Handling comment update - type: $type, postId: $postId");

      switch (type) {
        case 'created':
          final commentJson = commentData['comment'] as Map<String, dynamic>?;
          if (commentJson != null) {
            final newComment = Comment.fromJson(commentJson);
            // تأكد من أن التعليق ليس موجود بالفعل
            if (!comments.any((c) => c.id == newComment.id)) {
              comments.insert(0, newComment);
              debugPrint(
                  "✅ CommentCubit: New comment added, total comments: ${comments.length}");
              if (!isClosed) {
                emit(CommentsLoaded(List.from(comments)));
              }
            } else {
              debugPrint(
                  "⚠️ CommentCubit: Comment ${newComment.id} already exists");
            }
          } else {
            debugPrint("❌ CommentCubit: No comment data in created event");
          }
          break;

        case 'deleted':
          final commentId = commentData['commentId'] as int?;
          if (commentId != null) {
            comments.removeWhere((c) => c.id == commentId);
            debugPrint(
                "✅ CommentCubit: Comment $commentId deleted, remaining comments: ${comments.length}");
            if (!isClosed) {
              emit(CommentsLoaded(List.from(comments)));
            }
          }
          break;

        default:
          debugPrint("📡 CommentCubit: Unhandled comment event type: $type");
          break;
      }
    } catch (e) {
      debugPrint("❌ CommentCubit: Error handling comment update: $e");
      debugPrint("❌ CommentCubit: Stack trace: ${StackTrace.current}");
    }
  }

  Future<void> fetchComments(int postId) async {
    if (!isClosed) {
      emit(CommentLoading());
    }

    try {
      debugPrint("🔄 CommentCubit: Fetching comments for post $postId");

      // إلغاء الاشتراك من المنشور السابق إذا كان مختلفاً
      if (_currentPostId != null && _currentPostId != postId) {
        await _pusherService.unsubscribeFromPostComments(_currentPostId!);
        debugPrint(
            "🔄 CommentCubit: Unsubscribed from previous post $_currentPostId");
      }

      // الاشتراك في قناة التعليقات للمنشور
      await _pusherService.subscribeToPostComments(postId);
      _currentPostId = postId; // تخزين معرف المنشور الحالي

      final result = await apiComment.getComments(postId);
      result.fold(
        (failure) {
          debugPrint(
              "❌ CommentCubit: Failed to fetch comments: ${failure.message}");
          if (!isClosed) {
            emit(CommentError(failure.message));
          }
        },
        (listComments) {
          comments = listComments;
          debugPrint(
              "✅ CommentCubit: Fetched ${comments.length} comments for post $postId");
          if (!isClosed) {
            emit(CommentsLoaded(listComments));
          }
        },
      );
    } catch (e) {
      debugPrint("❌ CommentCubit: Unexpected error fetching comments: $e");
      if (!isClosed) {
        emit(CommentError("حدث خطأ غير متوقع: $e"));
      }
    }
  }

  Future<void> addComment(int postId, String content) async {
    // لا نرسل حالة التحميل عند إضافة تعليق جديد
    // emit(CommentLoading());

    try {
      debugPrint("🔄 CommentCubit: Adding comment to post $postId");
      final result = await apiComment.addComment(postId, content);
      result.fold(
        (failure) {
          debugPrint(
              "❌ CommentCubit: Failed to add comment: ${failure.message}");
          if (!isClosed) {
            emit(CommentError(failure.message));
          }
        },
        (newComment) {
          // لا نضيف التعليق هنا لأن Pusher سيرسله
          debugPrint("✅ CommentCubit: Comment added successfully via API");
          // لا نحتاج لإرسال حالة جديدة هنا لأن Pusher سيقوم بتحديث القائمة
        },
      );
    } catch (e) {
      debugPrint("❌ CommentCubit: Unexpected error adding comment: $e");
      if (!isClosed) {
        emit(CommentError("حدث خطأ غير متوقع: $e"));
      }
    }
  }

  Future<void> deleteComment(int commentId) async {
    // لا نرسل حالة التحميل عند حذف تعليق
    // emit(CommentLoading());

    try {
      debugPrint("🔄 CommentCubit: Deleting comment $commentId");
      final result = await apiComment.deleteComment(commentId);
      result.fold(
        (failure) {
          debugPrint(
              "❌ CommentCubit: Failed to delete comment: ${failure.message}");
          if (!isClosed) {
            emit(CommentError(failure.message));
          }
        },
        (_) {
          debugPrint("✅ CommentCubit: Comment deleted successfully via API");
          // لا نحتاج لإرسال حالة جديدة هنا لأن Pusher سيقوم بتحديث القائمة
        },
      );
    } catch (e) {
      debugPrint("❌ CommentCubit: Unexpected error deleting comment: $e");
      if (!isClosed) {
        emit(CommentError("حدث خطأ غير متوقع: $e"));
      }
    }
  }

  @override
  Future<void> close() {
    debugPrint("🔄 CommentCubit: Closing CommentCubit instance");
    _commentSubscription?.cancel();

    // إلغاء الاشتراك من قناة التعليقات للمنشور الحالي
    if (_currentPostId != null) {
      _pusherService.unsubscribeFromPostComments(_currentPostId!);
      debugPrint("✅ CommentCubit: Unsubscribed from post $_currentPostId");
    }

    debugPrint("✅ CommentCubit: Comment subscription cancelled");
    return super.close();
  }
}
