import 'package:flutter/material.dart';
import 'package:shamunity/models/notification_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class NotificationNavigationHelper {
  /// التنقل بناءً على نوع الإشعار
  static void handleNotificationTap(
      BuildContext context, NotificationModel notification) {
    // نوع الإشعار من payload_type في الجذر
    final payloadType = notification.payloadType;

    debugNotificationInfo(notification);

    if (payloadType == null) {
      debugPrint("⚠️ Notification payload_type is null");
      return;
    }

    switch (payloadType) {
      case 1:
        _navigateToPostDetails(context, notification);
        break;

      case 2:
        _navigateToAnnouncementsTab(context);
        debugPrint("🔗 Navigating to announcements tab in HomePage");
        break;

      case 3:
        debugPrint("📚 Library notification - No navigation needed");
        break;

      default:
        // أي نوع آخر: لا تفعل شيء
        debugPrint(
            "🚫 Notification type $payloadType - No navigation configured");
        break;
    }
  }

  /// التنقل إلى صفحة تفاصيل المنشور
  static void _navigateToPostDetails(
      BuildContext context, NotificationModel notification) {
    if (notification.payload == null) {
      debugPrint("⚠️ Notification payload is null for post navigation");
      return;
    }

    final post = notification.payload!.post;

    // التنقل إلى صفحة تفاصيل المنشور مع تمرير Post object

    context.pushNamed(
      RoutesNames.postDetails,
      arguments: post,
    );

    debugPrint("🔗 Navigating to post details with ID: ${post?.id}");
    debugPrint("📝 Post content: ${post?.content}");
  }

  /// التنقل إلى تبويب القرارات في الصفحة الرئيسية
  static void _navigateToAnnouncementsTab(BuildContext context) {
    // التنقل إلى الصفحة الرئيسية مع تحديد تبويب القرارات (رقم 3)
    context.pushReplacementNamed(
      RoutesNames.homePage,
      arguments: 3, // فهرس تبويب القرارات
    );

    debugPrint("🏠 Navigating to HomePage with announcements tab (index: 3)");
  }

  /// إظهار معلومات الإشعار للتشخيص
  static void debugNotificationInfo(NotificationModel notification) {
    debugPrint("📧 Notification Debug Info:");
    debugPrint("   - ID: ${notification.id}");
    debugPrint("   - Message: ${notification.message}");
    debugPrint("   - Payload Type: ${notification.payloadType}");
    debugPrint("   - Post ID: ${notification.payload?.post?.id}");
    debugPrint("   - Has Payload: ${notification.payload != null}");
    if (notification.payload != null) {
      debugPrint("   - Payload: ${notification.payload!.toJson()}");
    }
  }
}
