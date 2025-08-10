import 'dart:async'; // Added for StreamSubscription
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/post/api_post.dart';
import 'package:shamunity/models/post.dart';

import 'post_cubit_state.dart';

class PostCubit extends Cubit<PostCubitState> {
  final ApiPost apiPost;
  final PusherService _pusherService = PusherService();
  List<Post> posts = [];
  StreamSubscription<Map<String, dynamic>>? _postSubscription;
  StreamSubscription<Map<String, dynamic>>? _likeSubscription;

  PostCubit(this.apiPost) : super(PostCubitInitial()) {
    _initializePusher();
  }

  Future<void> _initializePusher() async {
    await _pusherService.initPusher();
    _listenToRealTimeUpdates();
  }

  void _listenToRealTimeUpdates() {
    _postSubscription = _pusherService.postStream.listen((postData) {
      if (!isClosed) {
        _handlePostUpdate(postData);
      }
    });

    _likeSubscription = _pusherService.likeStream.listen((likeData) {
      if (!isClosed) {
        _handleLikeUpdate(likeData);
      }
    });
  }

  void _handlePostUpdate(Map<String, dynamic> postData) {
    final action = postData['action'] as String;

    switch (action) {
      case 'created':
        final post = postData['post'] as Post;
        if (!posts.any((p) => p.id == post.id)) {
          posts.insert(0, post);
          if (!isClosed) {
            emit(PostCubitLoaded(List.from(posts)));
          }
        }
        break;
      case 'updated':
        final post = postData['post'] as Post;
        final index = posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          posts[index] = post;
          if (!isClosed) {
            emit(PostCubitLoaded(List.from(posts)));
          }
        }
        break;
      case 'deleted':
        final postId = postData['postId'] as int;
        posts.removeWhere((p) => p.id == postId);
        if (!isClosed) {
          emit(PostCubitLoaded(List.from(posts)));
        }
        break;
    }
  }

  void _handleLikeUpdate(Map<String, dynamic> likeData) {
    final postId = likeData['postId'] as int;
    final likesCount = likeData['likesCount'] as int;
    final isLiked = likeData['isLiked'] as bool? ?? false;

    debugPrint("📡 Pusher like update - Post ID: $postId");
    debugPrint("📡 Pusher like update - likesCount: $likesCount");
    debugPrint("📡 Pusher like update - isLiked: $isLiked");

    // البحث عن المنشور الحالي
    final currentPost = posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => Post(
        id: postId,
        content: '',
        likesCount: 0,
        commentsCount: 0,
        createdAt: '',
        author: Author.empty(),
      ),
    );

    debugPrint(
        "📡 Current local post - isLiked: ${currentPost.isLiked}, likesCount: ${currentPost.likesCount}");

    // تحديث البيانات من Pusher فقط إذا كانت البيانات المحلية متطابقة
    // أو إذا كانت البيانات المحلية قديمة
    if (currentPost.id == postId) {
      // تحديث البيانات من Pusher
      final updatedPosts = posts.map((post) {
        if (post.id == postId) {
          debugPrint(
              "🔄 Updating from Pusher - Old isLiked: ${post.isLiked}, New isLiked: $isLiked");
          return post.copyWith(
            likesCount: likesCount,
            isLiked: isLiked,
          );
        }
        return post;
      }).toList();

      posts = updatedPosts;
      if (!isClosed) {
        emit(PostCubitLoaded(updatedPosts));
        debugPrint("✅ Emitted PostCubitLoaded from Pusher update");
      }
    }
  }

  Future<void> fetchPosts() async {
    debugPrint("🔄 Fetching posts from server");
    emit(PostCubitLoading());

    final result = await apiPost.getPosts();
    result.fold(
      (failure) => emit(PostCubitError(failure.message)),
      (listPost) {
        debugPrint("✅ Server returned ${listPost.length} posts");

        // دمج البيانات الجديدة مع البيانات المحلية الموجودة
        final updatedPosts = listPost.map((newPost) {
          // البحث عن المنشور المحلي الموجود
          final existingPost = posts.firstWhere(
            (existing) => existing.id == newPost.id,
            orElse: () => newPost,
          );

          // الحفاظ على حالة isLiked المحلية إذا كانت موجودة
          // لأن البيانات المحلية قد تكون أحدث من الخادم
          if (existingPost.id == newPost.id) {
            debugPrint(
                "🔄 Merging post ${newPost.id} - Server isLiked: ${newPost.isLiked}, Local isLiked: ${existingPost.isLiked}");
            return newPost.copyWith(
              isLiked: existingPost.isLiked,
            );
          }

          return newPost;
        }).toList();

        posts = updatedPosts;
        if (!isClosed) {
          emit(PostCubitLoaded(updatedPosts));
          debugPrint("✅ Emitted PostCubitLoaded with merged posts");
        }
      },
    );
  }

  Future<void> createPost(
      {required String content, required File? image}) async {
    emit(PostCreatedLoading());
    final result = await apiPost.createPost(content, image);
    result.fold(
      (failure) =>
          emit(PostCreatedError(failure.message ?? "فشل إنشاء المنشور")),
      (createdPost) async {
        posts.insert(0, createdPost);
        emit(PostCreatedSuccess());
        emit(PostCubitSuccess());
      },
    );
  }

  Future<void> updatePost(int postId, Post post) async {
    emit(PostUpdatedLoading());
    final result = await apiPost.updatePost(postId, post);
    result.fold(
      (failure) =>
          emit(PostUpdatedError(failure.message ?? "فشل تعديل المنشور")),
      (updatedPost) async {
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) posts[index] = updatedPost;
        emit(PostUpdatedSuccess());
        emit(PostCubitSuccess());
      },
    );
  }

  Future<void> deletePost(int postId) async {
    emit(PostDeleteLoading("جاري حذف المنشور..."));
    final result = await apiPost.deletePost(postId);
    result.fold(
      (failure) => emit(PostDeletedError(failure.message ?? "فشل حذف المنشور")),
      (_) async {
        posts.removeWhere((p) => p.id == postId);
        emit(PostDeletedSuccess());
        emit(PostCubitSuccess());
      },
    );
  }

  Future<void> fetchUserPosts(int userId) async {
    emit(UserPostsLoading());
    final result = await apiPost.getUserPosts(userId);
    result.fold(
      (failure) => emit(UserPostsError(failure.message ?? "خطأ غير معروف")),
      (posts) {
        posts = posts;
        emit(UserPostsLoaded(posts));
        emit(PostCubitSuccess());
      },
    );
  }

  Future<void> toggleLike(int postId) async {
    try {
      debugPrint("🔄 Toggling like for post $postId");

      // إرسال للخادم والحصول على المنشور المحدث
      final updatedPost = await apiPost.toggleLike(postId);

      debugPrint("✅ Server response - Post ID: ${updatedPost.id}");
      debugPrint("✅ Server response - isLiked: ${updatedPost.isLiked}");
      debugPrint("✅ Server response - likesCount: ${updatedPost.likesCount}");

      // تحديث البيانات باستخدام المنشور المحدث من الخادم
      final updatedPosts = posts.map((post) {
        if (post.id == postId) {
          debugPrint(
              "🔄 Updating local post - Old isLiked: ${post.isLiked}, New isLiked: ${updatedPost.isLiked}");
          return updatedPost; // استخدام المنشور المحدث من الخادم
        }
        return post;
      }).toList();

      posts = updatedPosts;
      if (!isClosed) {
        emit(PostCubitLoaded(updatedPosts));
        debugPrint("✅ Emitted PostCubitLoaded with updated posts");
      }
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
      // لا نحدث أي شيء في حالة الخطأ
    }
  }

  @override
  Future<void> close() {
    _postSubscription?.cancel();
    _likeSubscription?.cancel();
    return super.close();
  }
}
