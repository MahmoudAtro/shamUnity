import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/post/api_post.dart';
import 'package:shamunity/models/post.dart';

import 'post_cubit_state.dart';

class PostCubit extends Cubit<PostCubitState> {
  final ApiPost apiPost;
  List<Post> posts = [];
  PostCubit(this.apiPost) : super(PostCubitInitial());

  Future<void> fetchPosts() async {
    if (!isClosed) {
      emit(PostUpdatedSuccess());
    }
    final result = await apiPost.getPosts();
    result.fold((failure) => emit(PostCubitError(failure.message)), (listPost) {
      posts = listPost;

      emit(PostCubitLoaded(listPost));
      // emit(PostCubitSuccess());
    });
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
      // تحديث محلي فوري لتجربة مستخدم أفضل
      if (state is PostCubitLoaded) {
        final currentPosts = (state as PostCubitLoaded).posts;
        final updatedPosts = currentPosts.map((post) {
          if (post.id == postId) {
            print("Post ${post.id} liked: ${post.isLiked}");

            final isLiked = !post.isLiked;
            print("Post ${post.id} liked: $isLiked");
            print("Post ${post.id} current: ${post.isLiked}");

            return post.copyWith(
              isLiked: isLiked,
              likesCount: isLiked ? post.likesCount + 1 : post.likesCount - 1,
            );
          }
          print("Post ${post.id} current: ${post.isLiked}");

          return post;
        }).toList();

        emit(PostCubitLoaded(updatedPosts));
      }

      // إرسال الطلب للخادم
      await apiPost.toggleLike(postId);
    } catch (e) {
      // التراجع عن التغييرات في حالة الخطأ
      if (state is PostCubitLoaded) {
        emit(PostCubitLoaded(List.from((state as PostCubitLoaded).posts)));
      }
      debugPrint('Error toggling like: $e');
    }
  }

  void listenToLikeUpdates() {
    apiPost.listenToLikeUpdates((postId, likesCount) {
      if (state is PostCubitLoaded) {
        final currentPosts = (state as PostCubitLoaded).posts;
        final updatedPosts = currentPosts.map((post) {
          if (post.id == postId) {
            return post.copyWith(likesCount: likesCount);
          }
          return post;
        }).toList();

        emit(PostCubitLoaded(updatedPosts));
      }
    });
  }

  void listenToNewPosts() {
    apiPost.listenToNewPostsAlternative((newPost) {
      posts.insert(0, newPost);
      emit(PostCubitLoaded(List<Post>.from(posts)));
    });
  }
}
