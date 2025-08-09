import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shamunity/models/chat_item_model.dart';

class ChatCardWidget extends StatelessWidget {
  final ChatItemModel chat;
  final VoidCallback onTap;

  const ChatCardWidget({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(chat.imageUrl),
      ),
      title:
          Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
          Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        DateFormat('hh:mm a').format(chat.lastMessageTime),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
