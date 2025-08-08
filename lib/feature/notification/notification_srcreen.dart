import 'package:flutter/material.dart';
import 'package:shamunity/feature/notification/widget/notification_card_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<NotificationModel> notifications = [
      NotificationModel(
        id: 'notif123',
        title: 'تم قبول طلبك',
        description: 'تمت الموافقة على تسجيلك في الدورة.',
        senderName: 'إدارة النظام',
        senderId: 'admin001',
        date: DateTime.now(),
      ),
      NotificationModel(
        id: 'notif124',
        title: 'تم إضافة مهمة جديدة',
        description: 'راجع قسم المهام لمعرفة التفاصيل.',
        senderName: 'إدارة النظام',
        senderId: 'admin001',
        date: DateTime.now(),
      ),
      NotificationModel(
        id: 'notif125',
        title: 'تم تحديث التطبيق',
        description: 'قم بتحديث التطبيق للاستفادة من الميزات الجديدة.',
        senderName: 'إدارة النظام',
        senderId: 'admin001',
        date: DateTime.now(),
      ),
      // يمكنك إضافة المزيد...
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationCardWidget(notification: notifications[index]);
        },
      ),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String senderName;
  final String senderId;
  final DateTime date;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.senderName,
    required this.senderId,
    required this.date,
  });
}
