import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/comment/comment_view.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_state.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';
import 'package:timeago/timeago.dart' as timeago;

class SheikhPostWidget extends StatefulWidget {
  final Post post;
  final Author? author;

  const SheikhPostWidget({
    Key? key,
    required this.post,
    this.author,
  }) : super(key: key);

  @override
  State<SheikhPostWidget> createState() => _SheikhPostWidgetState();
}

class _SheikhPostWidgetState extends State<SheikhPostWidget>
    with SingleTickerProviderStateMixin {
  late CommentCubit commentCubit;
  late AnimationController _likeController;

  @override
  void initState() {
    super.initState();

    commentCubit = getit<CommentCubit>();

    // إضافة التحريك للإعجاب
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    debugPrint(
        "✅ SheikhPostWidget: CommentCubit created for post ${widget.post.id}");
  }

  @override
  void dispose() {
    debugPrint(
        "🔄 SheikhPostWidget: Disposing CommentCubit for post ${widget.post.id}");
    commentCubit.close();
    _likeController.dispose();
    super.dispose();
  }

  // تنسيق التاريخ بشكل مناسب
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      // إذا كان أقل من 24 ساعة، استخدم timeago
      if (difference.inHours < 24) {
        timeago.setLocaleMessages('ar', timeago.ArMessages());
        return timeago.format(dateTime, locale: 'ar');
      } else {
        // إذا كان في نفس السنة
        if (dateTime.year == now.year) {
          return DateFormat('d MMMM', 'ar').format(dateTime);
        } else {
          return DateFormat('d MMMM y', 'ar').format(dateTime);
        }
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostCubitState>(
      builder: (context, state) {
        // البحث عن المنشور الحالي في قائمة المنشورات المحدثة
        Post currentPost = widget.post;
        if (state is PostCubitLoaded) {
          final updatedPost = state.posts.firstWhere(
            (post) => post.id == widget.post.id,
            orElse: () => widget.post,
          );
          currentPost = updatedPost;

          debugPrint("🔄 SheikhPostWidget - Post ${widget.post.id} updated");
          debugPrint(
              "🔄 SheikhPostWidget - Original isLiked: ${widget.post.isLiked}");
          debugPrint(
              "🔄 SheikhPostWidget - Updated isLiked: ${currentPost.isLiked}");
          debugPrint(
              "🔄 SheikhPostWidget - Original likesCount: ${widget.post.likesCount}");
          debugPrint(
              "🔄 SheikhPostWidget - Updated likesCount: ${currentPost.isLiked}");
        }

        // إذا كان المنشور محذوف، لا نعرضه
        if (state is PostCubitLoaded &&
            !state.posts.any((post) => post.id == widget.post.id)) {
          return const SizedBox.shrink(); // إخفاء المنشور المحذوف
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 1,
            color: Colors.white,
            child: Padding(
              // ✅ إرجاع البادينغ للـ Card
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ====== Header (LinkedIn style) ======
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    child: Row(
                      children: [
                        // صورة البروفايل (دائرية)
                        InkWell(
                          onTap: () {
                            context.pushNamed(RoutesNames.sheikhProfile,
                                arguments: widget.author?.id);
                          },
                          child: CircleAvatar(
                            radius: 22.r,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: widget.author?.profilePictureUrl !=
                                    null
                                ? NetworkImage(
                                    "${ApiConstances.baseUrlImg}${widget.author?.profilePictureUrl}")
                                : const AssetImage(
                                        "assets/images/default_avatar.jpg")
                                    as ImageProvider,
                          ),
                        ),

                        SizedBox(width: 10.w),

                        // الاسم + الوقت
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      context.pushNamed(
                                          RoutesNames.sheikhProfile,
                                          arguments: widget.author?.id);
                                    },
                                    child: Text(
                                      widget.author?.name ?? "Unknown",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  horizontalspace(5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.author?.college != null
                                          ? "${widget.author?.college} 🎓"
                                          : "Academic 🎓",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.blueAccent),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _formatDate(currentPost.createdAt.toString()),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: Colors.grey[300]),

                  // ====== نص البوست ======
                  if (currentPost.content.isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Text(
                        currentPost.content,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),

                  // ====== صورة البوست ======
                  if (currentPost.imageUrl != null)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12.r), // ✅ حواف دائرية للصورة
                      child: CachedNetworkImage(
                        imageUrl:
                            "${ApiConstances.baseUrlImg}${currentPost.imageUrl}",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => GlobalShimmer(
                          child: Container(
                            height: 220.h,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 220.h,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image,
                              size: 40.sp, color: Colors.grey[400]),
                        ),
                      ),
                    ),

                  SizedBox(height: 6.h),

                  // ====== عدد التفاعلات ======
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, // ✅ لمبة بدل إعجاب
                            size: 16.sp,
                            color: ColorsManager.gold.withOpacity(0.8)),
                        SizedBox(width: 4.w),
                        Text(
                          "${currentPost.likesCount}",
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey[700]),
                        ),
                        const Spacer(),
                        Text(
                          "${currentPost.commentsCount} تعليقات",
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: Colors.grey[300]),

                  // ====== أزرار التفاعل ======
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر أبدعت (بديل إعجاب)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              context
                                  .read<PostCubit>()
                                  .toggleLike(currentPost.id);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 20.sp,
                                    color: currentPost.isLiked
                                        ? ColorsManager.gold
                                        : Colors.grey[700],
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "أبدعت",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: currentPost.isLiked
                                          ? ColorsManager.gold
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              debugPrint("💾 حفظ البوست ${currentPost.id}");
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bookmark_border,
                                      size: 20.sp, color: Colors.grey[700]),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "حفظ",
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // زر تعليق (بديل مشاركة)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              commentCubit.fetchComments(currentPost.id);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor:
                                    Colors.transparent, // خليها شفاف
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20.r)),
                                ),
                                builder: (context) => BlocProvider.value(
                                  value: commentCubit,
                                  child: DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: 0.85,
                                    minChildSize: 0.5,
                                    maxChildSize: 0.9,
                                    builder: (_, controller) => ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20.r)),
                                      child: Container(
                                        color: Colors
                                            .white, // لازم تعطي لون الخلفية هنا
                                        child: CommentBottomSheet(
                                          post: currentPost,
                                          scrollController: controller,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.comment_outlined,
                                      size: 20.sp, color: Colors.grey[700]),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "تعليق",
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
