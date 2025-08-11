import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/cubit/comment_state.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/routes_name.dart';

class CommentBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Post post;

  const CommentBottomSheet({
    super.key,
    required this.scrollController,
    required this.post,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  late CommentCubit commentCubit;
  bool _hasText = false;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    commentCubit = context.read<CommentCubit>();
    _loadUserData();
    _commentController.addListener(_checkText);
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

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;
    commentCubit.addComment(widget.post.id, _commentController.text.trim());
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showDeleteDialog(int commentId) {
    if (user == null) {
      debugPrint("⚠️ User not loaded, cannot show delete dialog");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف التعليق"),
        content: const Text("هل أنت متأكد أنك تريد حذف هذا التعليق؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              commentCubit.deleteComment(commentId);
              Navigator.pop(context);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentCubit, CommentState>(
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildCommentList(state),
                ),
                _buildCommentInputField(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentList(CommentState state) {
    if (state is CommentLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is CommentError) {
      return Center(child: Text(state.failure));
    } else if (state is CommentsLoaded) {
      if (state.comments.isEmpty) {
        return const Center(
          child: Text(
            "لا توجد تعليقات",
            style: TextStyle(fontSize: 22),
          ),
        );
      }

      return ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.comments.length,
        itemBuilder: (context, index) {
          final comment = state.comments[index];
          return GestureDetector(
            onLongPress: () {
              if (user != null &&
                  user!.id.toString() == comment.author.id.toString()) {
                _showDeleteDialog(comment.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, RoutesNames.sheikhProfile,
                          arguments: comment.author.id);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: comment.author.profilePicture != null
                          ? NetworkImage(
                              "${ApiConstances.baseUrlImg}${comment.author.profilePicture}")
                          : null,
                      child: comment.author.name.isEmpty
                          ? Text(
                              comment.author.name,
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RoutesNames.sheikhProfile,
                                  arguments: comment.author.id);
                            },
                            child: Text(
                              softWrap: true,
                              maxLines: 1,
                              comment.author.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(comment.content),
                          Text(
                            comment.createdAt,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return const Center(child: Text("لا توجد تعليقات"));
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقًا...',
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
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          if (_hasText)
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _submitComment,
            ),
        ],
      ),
    );
  }
}
