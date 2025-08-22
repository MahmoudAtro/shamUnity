import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/connection_error.dart';
import 'package:shamunity/core/widgets/empty_data.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/post/widget/post_widget.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post bloc/cubit/post_cubit_state.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

UserModel? user;


class PostListScreen extends StatefulWidget {
  final bool isVisited;
  const PostListScreen({super.key, this.isVisited = false});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late PostCubit postCubit;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isVisited) {
      print("isVisited is false");
      _loadUserData();
    } else {
      print("isVisited is true");
      isLoading = false;
    }

    postCubit = PostCubit(getit());
    postCubit.fetchPosts();
  }

  Future<void> _loadUserData() async {
    user = await SecureSharedPrefHelper.getUser();
    debugPrint("🔄 Global user reloaded: ${user?.firstName} ${user?.lastName}");
    if (user != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    postCubit.close();
    super.dispose();
  }

  Widget buildPostShimmer() {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // صورة البروفايل
                CircleAvatar(
                  backgroundImage: user?.profilePictureUrl != null
                      ? NetworkImage(
                          "${ApiConstances.baseUrlImg}${user!.profilePictureUrl!}")
                      : const AssetImage('assets/images/default_avatar.jpg')
                          as ImageProvider,
                  radius: 22,
                ),
                const SizedBox(width: 10),

                // زر "بماذا تفكر؟" (يشبه فيسبوك)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      context.pushNamed(RoutesNames.createPost,
                          arguments: user);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.grey.shade100,
                      ),
                      child: const Text(
                        "بماذا تفكر؟",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // لمسة خاصة بالتطبيق (أيقونة إضافة صورة)
                IconButton(
                  onPressed: () {
                    context.pushNamed(RoutesNames.createPost, arguments: user);
                  },
                  icon: const Icon(Icons.edit, color: Colors.green, size: 24),
                  tooltip: "إضافة صورة",
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => postCubit,
      child: Scaffold(
        body: Column(
          
          children: [
            buildCreatePostCard(context),
            BlocBuilder<PostCubit, PostCubitState>(
              builder: (context, state) {
                if (state is PostCubitLoading || isLoading) {
                  return buildPostShimmer();
                } else if (state is PostCubitLoaded) {
                  if (state.posts.isEmpty) {
                    return const EmptyData(
                      message: "لا يوجد منشورات لعرضها",
                    );
                  }
                  final posts = state.posts;
                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => postCubit.fetchPosts(),
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return PostWidget(
                            isVisited: widget.isVisited,
                            post: posts[index],
                            author: posts[index].author!,
                          );
                        },
                      ),
                    ),
                  );
                } else if (state is PostCubitError) {
                  return ConnectionError(
                    message: state.message,
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
