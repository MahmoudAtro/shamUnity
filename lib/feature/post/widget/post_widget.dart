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
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostWidget extends StatefulWidget {
  final Post post;
  final Author author;

  final UserModel? user;

  const PostWidget({
    super.key,
    required this.post,
    required this.author,
    this.user,
  });
  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  bool _isDeleting = false;
  late PostCubit postCubit;
  late CommentCubit commentCubit;

  bool isLoading = true;
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

    debugPrint("✅ PostWidget: CommentCubit created for post ${widget.post.id}");
  }

  @override
  void dispose() {
    debugPrint(
        "🔄 PostWidget: Disposing CommentCubit for post ${widget.post.id}");
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      elevation: 10,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 5.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
                title: Text(
                  'تعديل المنشور',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  context.pushNamed(RoutesNames.editPost,
                      arguments: widget.post);
                },
              ),
              Divider(height: 1.h, color: Colors.grey.withOpacity(0.3)),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _isDeleting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : const Icon(Icons.delete, color: Colors.red),
                ),
                title: Text(
                  _isDeleting ? 'جاري الحذف...' : 'حذف المنشور',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: _isDeleting ? Colors.grey : Colors.black,
                  ),
                ),
                onTap: _isDeleting
                    ? null
                    : () async {
                        setState(() {
                          _isDeleting = true;
                        });

                        try {
                          await postCubit.deletePost(widget.post.id);
                          context.pop();
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isDeleting = false;
                            });
                          }
                        }
                      },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.user!.id.toString() == widget.author.id.toString();

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

          debugPrint("🔄 PostWidget - Post ${widget.post.id} updated");
          debugPrint(
              "🔄 PostWidget - Original isLiked: ${widget.post.isLiked}");
          debugPrint("🔄 PostWidget - Updated isLiked: ${currentPost.isLiked}");
          debugPrint(
              "🔄 PostWidget - Original likesCount: ${widget.post.likesCount}");
          debugPrint(
              "🔄 PostWidget - Updated likesCount: ${currentPost.isLiked}");
        }

        // إذا كان المنشور محذوف، لا نعرضه
        if (state is PostCubitLoaded &&
            !state.posts.any((post) => post.id == widget.post.id)) {
          return const SizedBox.shrink(); // إخفاء المنشور المحذوف
        }

        // معالجة أخطاء الحذف
        if (state is PostDeletedError) {
          // إظهار رسالة الخطأ
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          });
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
                                arguments: widget.author.id);
                          },
                          child: CircleAvatar(
                            radius: 22.r,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: widget.author.profilePictureUrl !=
                                    null
                                ? NetworkImage(
                                    "${ApiConstances.baseUrlImg}${widget.author.profilePictureUrl}")
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
                                      context.pushNamed(RoutesNames.sheikhProfile,
                                          arguments: widget.author.id);
                                    },
                                    child: Text(
                                      widget.author.name,
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
                                      widget.author.college != null
                                          ? "${widget.author.college} 🎓"
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

                        // زر الخيارات
                        if (isOwner)
                          IconButton(
                            icon: Icon(Icons.more_horiz,
                                color: Colors.grey[700], size: 22.sp),
                            onPressed: () => _showOptionsMenu(context),
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
                              postCubit.toggleLike(currentPost.id);
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

  Widget buildLikeButton(Post post, BuildContext context) {
    final isLiked = post.isLiked;
    final iconColor = isLiked ? ColorsManager.gold : Colors.grey[600];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint("🔄 PostWidget - Tapping like button");
          if (isLiked) {
            _likeController.reverse();
          } else {
            _likeController.forward(from: 0.0);
          }
          postCubit.toggleLike(post.id);
        },
        borderRadius: BorderRadius.circular(30.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Row(
            children: [
              Text(
                "${post.likesCount}",
                style: TextStyle(
                  color: iconColor,
                  fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(width: 6.w),
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                  CurvedAnimation(
                      parent: _likeController, curve: Curves.elasticOut),
                ),
                child: Icon(
                  isLiked ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: iconColor,
                  size: 26.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCommentButton(Post post, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint("🔄 PostWidget: Opening comments for post ${post.id}");
          commentCubit.fetchComments(post.id);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
        borderRadius: BorderRadius.circular(30.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Row(
            children: [
              Text(
                "${post.commentsCount}",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.comment_outlined,
                color: Colors.grey[600],
                size: 26.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
