import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/post/api_post.dart';
import 'package:shamunity/models/post.dart';

import 'post_cubit_state.dart';

class PostCubit extends Cubit<PostCubitState> {
  final ApiPost apiPost;

  PostCubit(this.apiPost) : super(PostCubitInitial());

  Future<void> fetchPosts() async {
    emit(PostCubitLoading());
    final result = await apiPost.getPosts();
    result.fold(
      (failure) => emit(PostCubitError(failure.message ?? "خطأ غير معروف")),
      (posts) => emit(PostCubitLoaded(posts)),
    );
  }

  Future<void> createPost(Post post) async {
    emit(PostCubitLoading());
    final result = await apiPost.createPost(post);
    result.fold(
      (failure) => emit(PostCubitError(failure.message ?? "فشل إنشاء المنشور")),
      (createdPost) async {
        await fetchPosts();
      },
    );
  }

  Future<void> updatePost(int postId, Post post) async {
    emit(PostCubitLoading());
    final result = await apiPost.updatePost(postId, post);
    result.fold(
      (failure) => emit(PostCubitError(failure.message ?? "فشل تعديل المنشور")),
      (updatedPost) async {
        await fetchPosts();
      },
    );
  }

  Future<void> deletePost(int postId) async {
    emit(PostCubitLoading());
    final result = await apiPost.deletePost(postId);
    result.fold(
      (failure) => emit(PostCubitError(failure.message ?? "فشل حذف المنشور")),
      (_) async {
        await fetchPosts();
      },
    );
  }

  Future<void> fetchUserPosts(String userId) async {
    emit(PostCubitLoading());
    final result = await apiPost.getUserPosts(userId);
    result.fold(
      (failure) => emit(PostCubitError(failure.message ?? "خطأ غير معروف")),
      (posts) => emit(PostCubitLoaded(posts)),
    );
  }
}
