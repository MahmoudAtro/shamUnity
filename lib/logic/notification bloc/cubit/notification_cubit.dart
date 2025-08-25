import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/notification/api_notification.dart';
import 'package:shamunity/models/notification_model.dart';

import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final ApiNotification notificationApi;

  List<NotificationModel> notifications = [];
  int unreadCount = 0;

  NotificationCubit({required this.notificationApi})
      : super(NotificationInitial()) {
    debugPrint("🔄 NotificationCubit initialized");
  }

  void cleanUnreadCount() {
    unreadCount = 0;
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      notifications.clear();
    }

    debugPrint("🔄 Fetching notifications from server");

    emit(NotificationLoading());

    final result = await notificationApi.getNotifications();
    await result.fold(
      (failure) async {
        debugPrint("❌ Error fetching notifications: ${failure.message}");
        emit(NotificationError(failure.message));
      },
      (response) async {
        debugPrint("✅ Server returned ${response.length} notifications");

        notifications = response;

        // حساب عدد الإشعارات غير المقروءة من البيانات المحملة
        unreadCount = notifications.where((n) => !n.isRead).length;

        if (!isClosed) {
          emit(NotificationLoaded(
            notifications: List.from(notifications),
            unreadCount: unreadCount,
          ));
          debugPrint(
              "✅ Emitted NotificationLoaded with ${notifications.length} notifications");
        }
      },
    );
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
