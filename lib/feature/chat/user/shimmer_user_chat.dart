import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MessageBubbleShimmer extends StatelessWidget {
  final bool isMe;
  final String type; // text, image, audio

  const MessageBubbleShimmer({
    super.key,
    required this.isMe,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case "text":
        return buildTextShimmer();
      case "image":
        return buildImageShimmer();
      case "audio":
        return buildAudioShimmer();
      default:
        return buildTextShimmer();
    }
  }

  // shimmer للرسالة النصية
  Widget buildTextShimmer() {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          width: 150,
          height: 20,
        ),
      ),
    );
  }

  // shimmer للرسالة الصورية
  Widget buildImageShimmer() {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          width: 180,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // shimmer للرسالة الصوتية
  Widget buildAudioShimmer() {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          width: 200,
          height: 40,
        ),
      ),
    );
  }
}
