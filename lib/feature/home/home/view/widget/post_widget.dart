import 'package:flutter/material.dart';
import 'package:shamunity/feature/home/home/view/ui/comment_view.dart';
import 'package:shamunity/models/cmment_model.dart';
import 'package:shamunity/models/post.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;

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
            // Header
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.post.userAvatarUrl),
              ),
              title: Text(widget.post.userName,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(widget.post.postTime),
              trailing: Icon(Icons.more_horiz),
            ),

            // Text Content
            if (widget.post.postText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(widget.post.postText),
              ),

            // Image
            if (widget.post.postImageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(widget.post.postImageUrl!),
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
                    label: "12",
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      print("تم الضغط على إعجاب");
                    },
                  ),
                  _PostAction(
                    icon: Icons.comment_outlined,
                    label: "31",
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.8,
                                minChildSize: 0.5,
                                maxChildSize: 0.9,
                                builder: (_, controller) => CommentBottomSheet(
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
    Key? key,
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
