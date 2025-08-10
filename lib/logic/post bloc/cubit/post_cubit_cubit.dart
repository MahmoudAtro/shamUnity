import 'dart:io';

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
      (failure) => emit(PostCubitError(failure.message)),
      (posts) => emit(PostCubitLoaded(posts)),
    );
  }

  Future<void> createPost(
      {required String content, required File? image}) async {
    emit(PostCreatedLoading());
    final result = await apiPost.createPost(content, image);
    result.fold(
      (failure) => emit(PostCubitError(failure.message)),
      (createdPost) async {
        emit(PostCreatedSuccess()); // حالة نجاح الإنشاء
        await fetchPosts();
      },
    );
  }

  Future<void> updatePost(int postId, Post post) async {
    emit(PostCubitLoading());
    final result = await apiPost.updatePost(postId, post);
    result.fold(
      (failure) => emit(PostCubitError(failure.message)),
      (updatedPost) async {
        await fetchPosts();
      },
    );
  }

  Future<void> deletePost(int postId) async {
    emit(PostCubitLoading());
    final result = await apiPost.deletePost(postId);
    result.fold(
      (failure) => emit(PostCubitError(failure.message)),
      (_) async {
        await fetchPosts();
      },
    );
  }

  Future<void> fetchUserPosts(String userId) async {
    emit(UserPostsLoading());
    final result = await apiPost.getUserPosts(userId);
    result.fold(
      (failure) => emit(PostCubitError(failure.message)),
      (posts) => emit(UserPostsLoaded(posts)),
    );
  }
}
