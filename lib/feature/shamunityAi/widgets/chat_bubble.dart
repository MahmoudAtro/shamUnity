import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamunity/models/chat_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.message));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ الرسالة!')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                message.time,
                style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}