import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/post/widget/post_widget.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_state.dart';
import 'package:shamunity/models/user_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class PostListScreen extends StatefulWidget {
  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late PostCubit postCubit;
  String? userId;
  String? userName;
  String? university;
  String? academicYear;
  String? avatarUrl;
  String? email;
  String? phone;

  @override
  void initState() {
    postCubit = BlocProvider.of<PostCubit>(context);
    postCubit.fetchPosts();
    _loadUserData();

    super.initState();
  }

  Future<void> _loadUserData() async {
    userId = await SecureSharedPrefHelper.getString("userId");
    userName = await SecureSharedPrefHelper.getString("userName");
    university = await SecureSharedPrefHelper.getString("university");
    academicYear = await SecureSharedPrefHelper.getString("academicYear");
    avatarUrl = await SecureSharedPrefHelper.getString("avatarUrl");
    email = await SecureSharedPrefHelper.getString("email");
    phone = await SecureSharedPrefHelper.getString("phone");
    setState(() {});
  }

  // يمكنك وضع هذا في أي ملف widgets أو مباشرة في صفحة عرض البوستات
  Widget buildPostShimmer() {
    return ListView.builder(
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
            context.pushNamed(RoutesNames.createPost,
                arguments: UserModel(
                    id: userId!,
                    name: userName!,
                    avatarUrl: avatarUrl!,
                    email: email!,
                    phone: phone!,
                    university: university!,
                    academicYear: academicYear!));
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/150?img=1"),
                  radius: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "إنشاء منشور جديد",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Icon(Icons.edit, color: Colors.grey),
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
      body: BlocBuilder<PostCubit, PostCubitState>(
        builder: (context, state) {
          if (state is PostCubitLoading) {
            return buildPostShimmer();
          } else if (state is PostCubitLoaded) {
            final posts = state.posts;
            return ListView.builder(
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildCreatePostCard(context);
                }
                return PostWidget(
                    post: posts[index - 1], author: posts[index - 1].author);
              },
            );
          } else if (state is PostCubitError) {
            return Center(child: Text(state.message));
          }
          // الحالة الافتراضية
          return const SizedBox();
        },
      ),
    );
  }
}
