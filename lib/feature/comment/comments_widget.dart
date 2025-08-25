import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/cubit/comment_state.dart';
import 'package:shamunity/models/comment.dart';

/// ودجت التعليقات القابل لإعادة الاستخدام
/// يمكن استخدامه في صفحة تفاصيل المنشور أو أي مكان آخر
class CommentsWidget extends StatelessWidget {
  final int postId;
  final CommentCubit? commentCubit;
  final VoidCallback? onRefresh;
  final bool showHeader;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const CommentsWidget({
    super.key,
    required this.postId,
    this.commentCubit,
    this.onRefresh,
    this.showHeader = true,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 1,
        color: Colors.white,
        child: Padding(
          padding: padding ?? EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // عنوان قسم التعليقات (اختياري)
              if (showHeader) _buildHeader(context),
              if (showHeader) Divider(height: 1, color: Colors.grey[300]),

              // قائمة التعليقات باستخدام CommentCubit
              BlocBuilder<CommentCubit, CommentState>(
                bloc: commentCubit,
                builder: (context, state) {
                  return _buildCommentsContent(context, state);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء عنوان قسم التعليقات
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 20.sp,
            color: Colors.grey[700],
          ),
          SizedBox(width: 8.w),
          Text(
            'التعليقات',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (onRefresh != null)
            IconButton(
              icon: Icon(
                Icons.refresh,
                size: 20.sp,
                color: Colors.grey[600],
              ),
              onPressed: onRefresh,
            ),
        ],
      ),
    );
  }

  /// بناء محتوى التعليقات بناءً على الحالة
  Widget _buildCommentsContent(BuildContext context, CommentState state) {
    if (state is CommentLoading) {
      return _buildLoadingState();
    }

    if (state is CommentError) {
      return _buildErrorState(context, state.failure);
    }

    if (state is CommentsLoaded) {
      if (state.comments.isEmpty) {
        return _buildEmptyState();
      }
      return _buildCommentsList(state.comments);
    }

    return _buildInitialState();
  }

  /// حالة التحميل
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.blue,
      ),
    );
  }

  /// حالة الخطأ
  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red[400],
            ),
            SizedBox(height: 8.h),
            Text(
              'خطأ في تحميل التعليقات',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              SizedBox(height: 12.h),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh, size: 16.sp),
                label: Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontSize: 12.sp),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// حالة عدم وجود تعليقات
  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12.h),
            Text(
              'لا توجد تعليقات بعد',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'كن أول من يعلق على هذا المنشور!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// حالة البداية
  Widget _buildInitialState() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: Text(
          'اضغط لتحميل التعليقات',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  /// قائمة التعليقات
  Widget _buildCommentsList(List<Comment> comments) {
    return Column(
      children: [
        // عداد التعليقات
        if (showHeader)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.comment,
                  size: 16.sp,
                  color: Colors.blue[600],
                ),
                SizedBox(width: 6.w),
                Text(
                  '${comments.length} تعليق',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

        // قائمة التعليقات
        ...comments.map((comment) => CommentItem(comment: comment)).toList(),

        // مساحة إضافية
        SizedBox(height: 8.h),
      ],
    );
  }
}

/// ودجت عنصر التعليق الواحد
class CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showReplyButton;

  const CommentItem({
    super.key,
    required this.comment,
    this.onTap,
    this.onLongPress,
    this.showReplyButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المعلق
            _buildAvatar(),
            SizedBox(width: 12.w),
            // محتوى التعليق
            Expanded(child: _buildCommentContent()),
          ],
        ),
      ),
    );
  }

  /// بناء صورة المعلق
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 18.r,
      backgroundColor: Colors.grey[300],
      backgroundImage: comment.author.profilePictureUrl != null
          ? NetworkImage(
              "${ApiConstances.baseUrlImg}${comment.author.profilePictureUrl}")
          : const AssetImage("assets/images/default_avatar.jpg")
              as ImageProvider,
    );
  }

  /// بناء محتوى التعليق
  Widget _buildCommentContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم المعلق
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.author.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
              // وقت التعليق
              Text(
                comment.createdAt,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // نص التعليق
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// ودجت مبسط للتعليقات (بدون كارد)
class SimpleCommentsWidget extends StatelessWidget {
  final int postId;
  final CommentCubit? commentCubit;
  final EdgeInsets? padding;

  const SimpleCommentsWidget({
    super.key,
    required this.postId,
    this.commentCubit,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(16.w),
      child: BlocBuilder<CommentCubit, CommentState>(
        bloc: commentCubit,
        builder: (context, state) {
          if (state is CommentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CommentsLoaded) {
            if (state.comments.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد تعليقات',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              );
            }

            return Column(
              children: state.comments
                  .map((comment) => CommentItem(comment: comment))
                  .toList(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
