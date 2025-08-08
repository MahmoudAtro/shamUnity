import 'package:flutter/material.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCardWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(
          Icons.notifications,
          color: Colors.blue,
          size: 30,
        ),
        title: Text(notification.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(notification.description),
        onTap: () {
          // يمكنك إضافة تنقل أو تفصيل هنا
        },
      ),
    );
  }
}
