import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/post/widget/post_widget.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_state.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

UserModel? user;

class PostListScreen extends StatefulWidget {
  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late PostCubit postCubit;
  bool isLoading = true;

  @override
  void initState() {
    _loadUserData();
    postCubit = BlocProvider.of<PostCubit>(context);
    postCubit.fetchPosts();
    super.initState();
  }

  Future<void> _loadUserData() async {
    user = await SecureSharedPrefHelper.getUser();
    if (user != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // يمكنك وضع هذا في أي ملف widgets أو مباشرة في صفحة عرض البوستات
  Widget buildPostShimmer() {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
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
                  // Header shimmer
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

  Widget buildCreatePostCard(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.pushNamed(RoutesNames.createPost, arguments: user);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: user!.profilePictureUrl != null
                      ? NetworkImage(user!.profilePictureUrl!)
                      : const AssetImage('assets/images/default_avatar.jpg'),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "إنشاء منشور جديد",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Icon(Icons.edit, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (user != null) buildCreatePostCard(context),
          BlocBuilder<PostCubit, PostCubitState>(
            builder: (context, state) {
              if (state is PostCubitLoading || isLoading) {
                return buildPostShimmer();
              } else if (state is PostCubitLoaded) {
                final posts = state.posts;
                return Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostWidget(
                          post: posts[index], author: posts[index].author);
                    },
                  ),
                );
              } else if (state is PostCubitError) {
                return Center(child: Text(state.message));
              }
              // الحالة الافتراضية
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
