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
    debugPrint("🔄 PostCubit initialized");
    _initializePusher();
  }

  Future<void> _initializePusher() async {
    debugPrint("🔄 PostCubit: Initializing Pusher...");
    try {
      await _pusherService.initPusher();
      debugPrint("✅ PostCubit: Pusher initialized successfully");
      _listenToRealTimeUpdates();
      debugPrint("✅ PostCubit: Real-time updates listener started");
    } catch (e) {
      debugPrint("❌ PostCubit: Failed to initialize Pusher: $e");
    }
  }

  void _listenToRealTimeUpdates() {
    debugPrint("🔄 PostCubit: Setting up stream listeners...");

    _postSubscription = _pusherService.postStream.listen((postData) {
      debugPrint("📡 PostCubit: Received post update: $postData");
      if (!isClosed) {
        _handlePostUpdate(postData);
      } else {
        debugPrint("⚠️ PostCubit: Cubit is closed, ignoring post update");
      }
    });

    _likeSubscription = _pusherService.likeStream.listen((likeData) {
      debugPrint("📡 PostCubit: Received like update: $likeData");
      if (!isClosed) {
        _handleLikeUpdate(likeData);
      } else {
        debugPrint("⚠️ PostCubit: Cubit is closed, ignoring like update");
      }
    });

    debugPrint("✅ PostCubit: Stream listeners set up successfully");
  }

  void _handlePostUpdate(Map<String, dynamic> postData) {
    debugPrint("🔄 PostCubit: Handling post update: $postData");

    final action = postData['action'] as String?;
    if (action == null) {
      debugPrint("⚠️ PostCubit: No action found in post data");
      return;
    }

    debugPrint("🔄 PostCubit: Action: $action");

    switch (action) {
      case 'created':
        debugPrint("🔄 PostCubit: Handling post created");
        final post = postData['post'] as Post?;
        if (post != null) {
          if (!posts.any((p) => p.id == post.id)) {
            posts.insert(0, post);
            debugPrint(
                "✅ PostCubit: New post added to list, total posts: ${posts.length}");
            if (!isClosed) {
              emit(PostCubitLoaded(List.from(posts)));
              debugPrint("✅ PostCubit: Emitted PostCubitLoaded for new post");
            }
          } else {
            debugPrint("⚠️ PostCubit: Post ${post.id} already exists in list");
          }
        } else {
          debugPrint("❌ PostCubit: No post data found in created event");
        }
        break;

      case 'updated':
        debugPrint("🔄 PostCubit: Handling post updated");
        final post = postData['post'] as Post?;
        if (post != null) {
          final index = posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            posts[index] = post;
            debugPrint("✅ PostCubit: Post ${post.id} updated in list");
            if (!isClosed) {
              emit(PostCubitLoaded(List.from(posts)));
              debugPrint(
                  "✅ PostCubit: Emitted PostCubitLoaded for updated post");
            }
          } else {
            debugPrint(
                "⚠️ PostCubit: Post ${post.id} not found in list for update");
          }
        } else {
          debugPrint("❌ PostCubit: No post data found in updated event");
        }
        break;

      case 'deleted':
        debugPrint("🔄 PostCubit: Handling post deleted");
        final postId = postData['postId'] as int?;
        if (postId != null) {
          final initialLength = posts.length;
          posts.removeWhere((p) => p.id == postId);
          final finalLength = posts.length;
          debugPrint(
              "✅ PostCubit: Post $postId removed from list (${initialLength} -> ${finalLength})");
          if (!isClosed) {
            emit(PostCubitLoaded(List.from(posts)));
            debugPrint("✅ PostCubit: Emitted PostCubitLoaded for deleted post");
          }
        } else {
          debugPrint("❌ PostCubit: No postId found in deleted event");
        }
        break;

      default:
        debugPrint("⚠️ PostCubit: Unknown action: $action");
        break;
    }
  }

  void _handleLikeUpdate(Map<String, dynamic> likeData) {
    debugPrint("🔄 PostCubit: Handling like update: $likeData");

    final postId = likeData['postId'] as int?;
    final likesCount = likeData['likesCount'] as int?;
    final isLiked = likeData['isLiked'] as bool? ?? false;

    if (postId == null) {
      debugPrint("❌ PostCubit: No postId found in like data");
      return;
    }

    if (likesCount == null) {
      debugPrint("❌ PostCubit: No likesCount found in like data");
      return;
    }

    debugPrint(
        "📡 PostCubit: Like update - Post ID: $postId, likesCount: $likesCount, isLiked: $isLiked");

    // البحث عن المنشور وتحديثه مباشرة
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final oldPost = posts[postIndex];
      debugPrint("📡 PostCubit: Found post $postId at index $postIndex");
      debugPrint(
          "📡 PostCubit: Old state - isLiked: ${oldPost.isLiked}, likesCount: ${oldPost.likesCount}");

      final updatedPost = oldPost.copyWith(
        likesCount: likesCount,
        isLiked: isLiked,
      );

      posts[postIndex] = updatedPost;
      debugPrint(
          "📡 PostCubit: Updated post $postId - New isLiked: $isLiked, New likesCount: $likesCount");

      if (!isClosed) {
        emit(PostCubitLoaded(List.from(posts)));
        debugPrint("✅ PostCubit: Emitted PostCubitLoaded for like update");
      } else {
        debugPrint("⚠️ PostCubit: Cubit is closed, cannot emit state");
      }
    } else {
      debugPrint("⚠️ PostCubit: Post $postId not found in local posts list");
      debugPrint(
          "📡 PostCubit: Available post IDs: ${posts.map((p) => p.id).toList()}");
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

        // تحديث القائمة بالكامل مع الحفاظ على البيانات المحلية المحدثة
        final updatedPosts = listPost.map((newPost) {
          // البحث عن المنشور المحلي الموجود
          final existingPost = posts.firstWhere(
            (existing) => existing.id == newPost.id,
            orElse: () => newPost,
          );

          // الحفاظ على حالة isLiked المحلية إذا كانت موجودة
          if (existingPost.id == newPost.id &&
              existingPost.isLiked != newPost.isLiked) {
            debugPrint("🔄 Preserving local like state for post ${newPost.id}");
            return newPost.copyWith(
              isLiked: existingPost.isLiked,
            );
          }

          return newPost;
        }).toList();

        posts = updatedPosts;
        if (!isClosed) {
          emit(PostCubitLoaded(updatedPosts));
          debugPrint(
              "✅ Emitted PostCubitLoaded with ${updatedPosts.length} posts");
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
        // إضافة المنشور الجديد إلى القائمة المحلية
        posts.insert(0, createdPost);

        // إرسال الحالة المحدثة
        if (!isClosed) {
          emit(PostCreatedSuccess());
          emit(PostCubitLoaded(List.from(posts)));
          debugPrint("✅ Post created and added to local list");
        }
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
        // تحديث المنشور في القائمة المحلية
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          posts[index] = updatedPost;

          if (!isClosed) {
            emit(PostUpdatedSuccess());
            emit(PostCubitLoaded(List.from(posts)));
            debugPrint("✅ Post updated in local list");
          }
        }
      },
    );
  }

  Future<void> deletePost(int postId) async {
    emit(PostDeleteLoading("جاري حذف المنشور..."));
    final result = await apiPost.deletePost(postId);
    result.fold(
      (failure) => emit(PostDeletedError(failure.message ?? "فشل حذف المنشور")),
      (_) async {
        // حذف المنشور من القائمة المحلية
        posts.removeWhere((p) => p.id == postId);

        if (!isClosed) {
          emit(PostDeletedSuccess());
          emit(PostCubitLoaded(List.from(posts)));
          debugPrint("✅ Post deleted from local list");
        }
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

      // تحديث البيانات المحلية بالمنشور المحدث من الخادم
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        posts[postIndex] = updatedPost;

        if (!isClosed) {
          emit(PostCubitLoaded(List.from(posts)));
          debugPrint("✅ Post like toggled and local data updated");
        }
      }
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
      // إرسال حالة الخطأ
      if (!isClosed) {
        emit(PostLikeToggleError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _postSubscription?.cancel();
    _likeSubscription?.cancel();
    return super.close();
  }
}
