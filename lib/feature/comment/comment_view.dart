import 'package:flutter/material.dart';
import 'package:shamunity/models/cmment_model.dart' show CommentModel;

class CommentBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<CommentModel> comments;

  const CommentBottomSheet({
    super.key,
    required this.scrollController,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: comment.avatarUrl.isNotEmpty
                    ? NetworkImage(comment.avatarUrl)
                    : null,
                child: comment.avatarUrl.isEmpty
                    ? Text(
                        comment.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        softWrap: true,
                        maxLines: 1,
                        comment.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 1),
                      Text(comment.text),
                      Text(
                        timeAgo(comment.timestamp),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return '${difference.inMinutes} د';
    if (difference.inHours < 24) return '${difference.inHours} س';
    return '${difference.inDays} يوم';
  }
}
