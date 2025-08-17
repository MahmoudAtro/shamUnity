import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/models/user_message.dart';

class ChatCardWidget extends StatelessWidget {
  final UserMessage conversation;
  final int? unreadCount;
  final VoidCallback onTap;
  final String lastMessage;
  final DateTime createdAt;

  const ChatCardWidget({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.unreadCount,
    required this.lastMessage,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = unreadCount! > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                  "${ApiConstances.baseUrlImg}${conversation.profilePictureUrl}"),
              // Add a fallback for if the image fails or is null
              onBackgroundImageError: (exception, stackTrace) {},
              child: conversation.profilePictureUrl == null
                  ? Text(
                      conversation.name.isNotEmpty ? conversation.name[0] : 'م',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            // Name and Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600, // Bolder name
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold, // Bold if unread
                      color: hasUnread
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Timestamp and Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  extractTimeParts(
                    createdAt.toIso8601String(),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                // Show the unread badge only if there are unread messages
                if (hasUnread)
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.green, // WhatsApp-like color
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  // Add an empty SizedBox to maintain alignment
                  const SizedBox(height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String extractTimeParts(String dateTimeString) {
    // تحويل النص إلى كائن DateTime مع الحفاظ على فرق التوقيت
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();

    // صيغة الوقت مع AM/PM
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return formattedTime;
  }
}
