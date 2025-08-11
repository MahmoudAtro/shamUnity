import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/feature/post/widget/post_widget.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_state.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostCubit>().fetchUserPosts(user!.id);
    });
  }

  Widget buildPostShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                if (user != null)
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: user!.profilePictureUrl != null
                        ? NetworkImage(
                            "${ApiConstances.baseUrlImg}${user!.profilePictureUrl!}")
                        : const AssetImage('assets/images/default_avatar.jpg')
                            as ImageProvider,
                  ),
                const SizedBox(height: 16),
                if (user != null)
                  Text(
                    "${user!.firstName} ${user!.lastName}",
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                if (user != null)
                  Text(
                    user!.college,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                if (user != null)
                  Text(
                    user!.email,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const TabBar(
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.black,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: "المنشورات"),
                        Tab(text: "الملفات"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 500, // يمكنك تعديل الارتفاع حسب الحاجة
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // تبويب المنشورات
                      BlocBuilder<PostCubit, PostCubitState>(
                        builder: (context, state) {
                          if (state is UserPostsError) {
                            print("Error fetching user posts: ${state.message}");
                            return Center(child: Text(state.message));

                          } else if (state is UserPostsLoading) {
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
                                      ))
                                  .toList(),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      // تبويب الملفات (يمكنك استبداله بملفات المستخدم)
                      Center(
                        child: Text(
                          "لا توجد ملفات حتى الآن",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
