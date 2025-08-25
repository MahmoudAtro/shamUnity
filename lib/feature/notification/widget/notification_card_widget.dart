import 'package:flutter/material.dart';
import 'package:shamunity/models/notification_model.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : Colors.blue[50]?.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الإشعار في دائرة ملونة (مثل فيسبوك)
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نص الإشعار
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.w400
                            : FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),

                    // محتوى إضافي من payload إذا وجد
                    if (notification.payload?.post?.content != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        notification.payload!.post!.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 6),
                    // التاريخ
                    Text(
                      notification.createdAt,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // نقطة زرقاء للإشعارات غير المقروءة (مثل فيسبوك)
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.payloadType) {
      case 'announcement':
        return Icons.campaign;
      case 'message':
        return Icons.message;
      case 'reminder':
        return Icons.schedule;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconBackgroundColor() {
    switch (notification.payloadType) {
      case 'announcement':
        return Colors.orange;
      case 'message':
        return Colors.green;
      case 'reminder':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
