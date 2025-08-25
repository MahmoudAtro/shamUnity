import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/feature/comment/shimmer_comments_view.dart';
import 'package:shamunity/feature/post/widget/post_widget.dart';
import 'package:shamunity/logic/index.dart';
import 'package:shamunity/models/post.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostCubit postCubit;
  late CommentCubit commentCubit;
  final TextEditingController _commentController = TextEditingController();
  bool _hasText = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    postCubit = getit<PostCubit>();
    commentCubit = getit<CommentCubit>();
    commentCubit.fetchComments(widget.post.id);
    _commentController.addListener(_checkText);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _checkText() {
    setState(() {
      _hasText = _commentController.text.trim().isNotEmpty;
    });
  }

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await commentCubit.addComment(
          widget.post.id, _commentController.text.trim());
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: postCubit),
        BlocProvider.value(value: commentCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // محتوى الصفحة القابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 40),

                    PostWidget(
                        post: widget.post,
                        author: widget.post.author,
                        showFooter: false),

                    // قسم التعليقات بدون حقل الإدخال
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),

            // حقل إدخال التعليق ثابت في الأسفل
            _buildCommentInputField(),
          ],
        ),
      ),
    );
  }

  /// بناء قسم التعليقات بدون حقل الإدخال
  Widget _buildCommentsSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان قسم التعليقات
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'التعليقات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),

            // قائمة التعليقات
            BlocBuilder<CommentCubit, CommentState>(
              bloc: commentCubit,
              builder: (context, state) {
                return _buildCommentsContent(context, state);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// حقل إدخال التعليق في أسفل الشاشة
  Widget _buildCommentInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: _isSubmitting ? 'جاري الإرسال...' : 'اكتب تعليقًا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _isSubmitting ? null : (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          if (_hasText)
            IconButton(
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.blue),
              onPressed: _isSubmitting ? null : _submitComment,
            ),
        ],
      ),
    );
  }

  /// بناء محتوى التعليقات
  Widget _buildCommentsContent(BuildContext context, CommentState state) {
    if (state is CommentLoading) {
      return const ShimmerCommentsView();
    }

    if (state is CommentError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 8),
              Text(
                'خطأ في تحميل التعليقات',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.failure,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state is CommentsLoaded) {
      if (state.comments.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد تعليقات بعد',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'كن أول من يعلق على هذا المنشور!',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: state.comments.map((comment) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المعلق
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: comment.author.profilePictureUrl != null
                      ? NetworkImage(comment.author.profilePictureUrl!)
                      : const AssetImage("assets/images/default_avatar.jpg")
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                // محتوى التعليق
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المعلق والوقت
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                comment.author.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              comment.createdAt,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // نص التعليق
                        Text(
                          comment.content,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }
}
