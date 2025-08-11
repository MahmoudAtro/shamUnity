import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/comment/comment_view.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/routes/routes_name.dart';

class SheikhPostWidget extends StatelessWidget {
  final Post post;
  final Author author;

  const SheikhPostWidget({
    Key? key,
    required this.post,
    required this.author,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.2),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - نفس تصميم PostWidget

            ListTile(
              leading: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RoutesNames.sheikhProfile,
                      arguments: author.id);
                },
                child: GlobalShimmer(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: author.profilePicture != null
                          ? DecorationImage(
                              image: NetworkImage(
                                "${ApiConstances.baseUrlImg}${author.profilePicture}",
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              title: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RoutesNames.sheikhProfile,
                      arguments: author.id);
                },
                child: Text(
                  author.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text(post.createdAt.toString()),
              // لا نحتاج trailing لأن هذا منشور في الملف الشخصي
            ),

            // Text Content - نفس تصميم PostWidget
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(post.content),
              ),

            // Image - نفس تصميم PostWidget
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  "${ApiConstances.baseUrlImg}${post.imageUrl}",
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

            // Actions - نفس تصميم PostWidget مع وظائف حقيقية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocProvider(
                    create: (context) => getit<PostCubit>(),
                    child: _PostAction(
                      color: post.isLiked ? Colors.blue : Colors.grey,
                      icon: post.isLiked
                          ? Icons.lightbulb
                          : Icons.lightbulb_outline,
                      label: "${post.likesCount}",
                      onTap: () {
                        // استدعاء دالة الإعجاب
                        context.read<PostCubit>().toggleLike(post.id);
                      },
                    ),
                  ),
                  BlocProvider(
                    create: (context) => getit<CommentCubit>(),
                    child: _PostAction(
                      icon: Icons.comment_outlined,
                      label: "${post.commentsCount}",
                      onTap: () {
                        // استدعاء دالة جلب التعليقات وعرضها
                        final commentCubit = context.read<CommentCubit>();
                        commentCubit.fetchComments(post.id);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => BlocProvider.value(
                            value: commentCubit,
                            child: DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.8,
                              minChildSize: 0.5,
                              maxChildSize: 0.9,
                              builder: (_, controller) => CommentBottomSheet(
                                post: post,
                                scrollController: ScrollController(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// نفس كلاس _PostAction من PostWidget
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
