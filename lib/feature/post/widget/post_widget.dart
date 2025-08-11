import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/comment/comment_view.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_state.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final Author author;

  const PostWidget({Key? key, required this.post, required this.author})
      : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late PostCubit postCubit;
  late CommentCubit commentCubit;
  UserModel? user; // إضافة متغير user

  @override
  void initState() {
    super.initState();
    postCubit = BlocProvider.of<PostCubit>(context);
    // إنشاء CommentCubit جديد لكل PostWidget
    commentCubit = getit<CommentCubit>();
    debugPrint("✅ PostWidget: CommentCubit created for post ${widget.post.id}");
    _loadUserData(); // تحميل بيانات المستخدم
  }

  @override
  void dispose() {
    debugPrint(
        "🔄 PostWidget: Disposing CommentCubit for post ${widget.post.id}");
    commentCubit.close(); // إغلاق CommentCubit
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      user = await SecureSharedPrefHelper.getUser();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("❌ Error loading user data: $e");
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('تعديل المنشور',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  context.pushNamed(RoutesNames.editPost,
                      arguments: widget.post);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف المنشور',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  postCubit.deletePost(widget.post.id);
                  context.pop();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // فحص null للمتغير user
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isOwner = user!.id.toString() == widget.author.id.toString();
    print(isOwner);
    print("=================================");
    print(widget.author.id.toString());
    print("=================================");

    print(user!.id.toString());

    return BlocListener<PostCubit, PostCubitState>(
      listenWhen: (previous, current) =>
          isOwner &&
          (current is PostDeletedSuccess || current is PostDeletedError),
      listener: (context, state) {
        if (state is PostDeleteLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is PostDeletedSuccess) {
          Navigator.of(context).pop(); // إغلاق dialog التحميل
          Toast().success(context, "تم حذف المنشور بنجاح");
          Navigator.of(context).pop(); // العودة للصفحة السابقة
        } else if (state is PostDeletedError) {
          Navigator.of(context).pop(); // إغلاق dialog التحميل
          Toast().error(context, state.message);
        }
      },
      child: BlocBuilder<PostCubit, PostCubitState>(
        builder: (context, state) {
          // البحث عن المنشور الحالي في قائمة المنشورات المحدثة
          Post currentPost = widget.post;
          if (state is PostCubitLoaded) {
            final updatedPost = state.posts.firstWhere(
              (post) => post.id == widget.post.id,
              orElse: () => widget.post,
            );
            currentPost = updatedPost;

            debugPrint("🔄 PostWidget - Post ${widget.post.id} updated");
            debugPrint(
                "🔄 PostWidget - Original isLiked: ${widget.post.isLiked}");
            debugPrint(
                "🔄 PostWidget - Updated isLiked: ${currentPost.isLiked}");
            debugPrint(
                "🔄 PostWidget - Original likesCount: ${widget.post.likesCount}");
            debugPrint(
                "🔄 PostWidget - Updated likesCount: ${currentPost.likesCount}");
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.white,
            shadowColor: Colors.grey.withOpacity(0.2),
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            child: Column(
              children: [
                // Header
                ListTile(
                  // ...existing code...
                  leading: InkWell(
                    onTap: () {
                      context.pushNamed(RoutesNames.sheikhProfile,
                          arguments: widget.author.id);
                    },
                    child: GlobalShimmer(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: widget.author.profilePicture != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    "${ApiConstances.baseUrlImg}${widget.author.profilePicture}",
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  // ...existing code...
                  title: InkWell(
                    onTap: () {
                      context.pushNamed(RoutesNames.sheikhProfile,
                          arguments: widget.author.id);
                    },
                    child: Text(widget.author.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),

                  subtitle: Text(currentPost.createdAt.toString()),
                  trailing: isOwner
                      ? IconButton(
                          icon: const Icon(Icons.more_horiz),
                          onPressed: () => _showOptionsMenu(context),
                        )
                      : null,
                ),
                // Text Content
                if (currentPost.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(currentPost.content),
                  ),

                // Image
                if (currentPost.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image.network(
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      "${ApiConstances.baseUrlImg}${currentPost.imageUrl}",
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return GlobalShimmer(
                          child: Container(
                            height: 220,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),

                const Divider(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PostAction(
                        color: currentPost.isLiked ? Colors.blue : Colors.grey,
                        icon: currentPost.isLiked
                            ? Icons.lightbulb
                            : Icons.lightbulb_outline,
                        label: "${currentPost.likesCount}",
                        onTap: () {
                          debugPrint("🔄 PostWidget - Tapping like button");
                          debugPrint(
                              "🔄 PostWidget - Current isLiked: ${currentPost.isLiked}");
                          debugPrint(
                              "🔄 PostWidget - Current likesCount: ${currentPost.likesCount}");

                          postCubit.toggleLike(currentPost.id);

                          print("تم الضغط على إعجاب");
                        },
                      ),
                      _PostAction(
                        icon: Icons.comment_outlined,
                        label: "${currentPost.commentsCount}",
                        onTap: () {
                          debugPrint(
                              "🔄 PostWidget: Opening comments for post ${currentPost.id}");
                          // استخدم CommentCubit الموجود بدلاً من إنشاء واحد جديد
                          commentCubit.fetchComments(currentPost.id);
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) => BlocProvider.value(
                                    value: commentCubit,
                                    child: DraggableScrollableSheet(
                                      expand: false,
                                      initialChildSize: 0.8,
                                      minChildSize: 0.5,
                                      maxChildSize: 0.9,
                                      builder: (_, controller) =>
                                          CommentBottomSheet(
                                        post: currentPost,
                                        scrollController: ScrollController(),
                                      ),
                                    ),
                                  ));
                        },
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _PostAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Text(label, style: TextStyle(color: color ?? Colors.grey[700])),
            const SizedBox(width: 3),
            Icon(icon, size: 28, color: color ?? Colors.grey[700]),
          ],
        ),
      ),
    );
  }
}
