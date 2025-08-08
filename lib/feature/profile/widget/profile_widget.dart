import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/feature/post/widget/post_widget.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_state.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String? userId;
  String? userName;
  String? university;
  late PostCubit postCubit;
  // أضف باقي البيانات التي تحتاجها هنا

  @override
  void initState() {
    postCubit = BlocProvider.of<PostCubit>(context);
    postCubit.fetchUserPosts(userId!);
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userId = await SecureSharedPrefHelper.getString("userId");
    userName = await SecureSharedPrefHelper.getString("userName");
    university = await SecureSharedPrefHelper.getString("university");
    // أضف باقي البيانات هنا بنفس الطريقة

    // استدعاء جلب بوستات المستخدم من الكيوبت
    if (userId != null && userId!.isNotEmpty) {
      postCubit.fetchUserPosts(userId!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostCubitState>(
      builder: (context, state) {
        if (state is PostCubitLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PostCubitLoaded) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Column(
                  children: [
                    Text(userName ?? '', style: const TextStyle(fontSize: 30)),
                    Text(university ?? '',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("المنشورات",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...state.posts
                  .map((post) => PostWidget(
                      post: post, author: post.author, currentUserId: userId!))
                  .toList(),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
