import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/widgets/global_shimmer.dart';
import 'package:shamunity/feature/comment/comment_view.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_state.dart';
import 'package:shamunity/models/cmment_model.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final Author author;
  final String? currentUserId;

  const PostWidget(
      {Key? key, required this.post, required this.author, this.currentUserId})
      : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  late PostCubit postCubit;

  @override
  void initState() {
    super.initState();
    postCubit = BlocProvider.of<PostCubit>(context);
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
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('تعديل المنشور'),
                onTap: () {
                  context.pushNamed(RoutesNames.editPost,
                      arguments: widget.post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('حذف المنشور'),
                onTap: () {
                  postCubit.deletePost(widget.post.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.currentUserId == widget.author.id.toString();

    return BlocListener<PostCubit, PostCubitState>(
      listenWhen: (previous, current) =>
          isOwner &&
          (current is PostDeletedSuccess || current is PostDeletedError),
      listener: (context, state) {
        if (state is PostDeletedSuccess) {
          Toast().success(context, "تم حذف المنشور بنجاح");
        } else if (state is PostDeletedError) {
          Toast().error(context, state.message);
        }
      },
      child: Card(
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
              // Header
              ListTile(
                // ...existing code...
                leading: GlobalShimmer(
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
// ...existing code...
                title: Text(widget.author.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.post.createdAt.toString()),
                trailing: isOwner
                    ? IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () => _showOptionsMenu(context),
                      )
                    : null,
              ),

              // Text Content
              if (widget.post.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(widget.post.content),
                ),

              // Image
              if (widget.post.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.network(
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    "${ApiConstances.baseUrlImg}${widget.post.imageUrl}",
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

              // Actions (Like / Comment)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PostAction(
                      color: isLiked ? Colors.blue : Colors.grey,
                      icon: isLiked ? Icons.lightbulb : Icons.lightbulb_outline,
                      label: "${widget.post.likesCount}",
                      onTap: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                        print("تم الضغط على إعجاب");
                      },
                    ),
                    _PostAction(
                      icon: Icons.comment_outlined,
                      label: "${widget.post.commentsCount}",
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) => DraggableScrollableSheet(
                                  expand: false,
                                  initialChildSize: 0.8,
                                  minChildSize: 0.5,
                                  maxChildSize: 0.9,
                                  builder: (_, controller) =>
                                      CommentBottomSheet(
                                    scrollController: ScrollController(),
                                    comments: [
                                      CommentModel(
                                        username: 'محمد',
                                        text:
                                            'هذا تعليق رائع! asdasdas      يشسيشسسسسسسش          شسيسشيشسيشيشسي                     شسيس              شيس',
                                        timestamp: DateTime.now()
                                            .subtract(Duration(minutes: 5)),
                                      ),
                                      CommentModel(
                                        username: 'سارة',
                                        text: 'أوافقك الرأي 👍',
                                        timestamp: DateTime.now()
                                            .subtract(Duration(hours: 1)),
                                      ),
                                    ],
                                  ),
                                ));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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
