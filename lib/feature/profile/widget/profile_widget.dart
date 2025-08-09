import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/feature/post/widget/post_widget.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_state.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late PostCubit postCubit;

  @override
  void initState() {
    super.initState();
    postCubit = BlocProvider.of<PostCubit>(context);
    postCubit.fetchUserPosts(user!.id.toString());
    // جلب بيانات المستخدم من SharedPreferences أو أي مصدر آخر
  }

  Widget buildPostShimmer() {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GlobalShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 120,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // عرض بيانات المستخدم مباشرة
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              CircleAvatar(
                radius: 80,
                backgroundImage: user!.profilePictureUrl != null
                    ? NetworkImage(user!.profilePictureUrl!)
                    : const AssetImage('assets/images/default_avatar.jpg')
                        as ImageProvider,
              ),
              const SizedBox(height: 16),

              Text(
                "${user!.firstName} ${user!.lastName}",
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              Text(
                user!.college,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Text("المنشورات",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // قسم المنشورات يستمع للبلوك فقط
              BlocBuilder<PostCubit, PostCubitState>(
                builder: (context, state) {
                  if (state is UserPostsLoading) {
                    return buildPostShimmer();
                  } else if (state is UserPostsLoaded) {
                    if (state.posts.isEmpty) {
                      return const Center(
                          child: Text("لا توجد منشورات لعرضها"));
                    }
                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: state.posts
                          .map((post) => PostWidget(
                              post: post,
                              author: post.author,
                              currentUserId: user!.id.toString()))
                          .toList(),
                    );
                  } else if (state is PostCubitError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
