import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/feature/notification/notification_navigation_helper.dart';
import 'package:shamunity/feature/notification/widget/notification_card_widget.dart';
import 'package:shamunity/logic/notification bloc/cubit/notification_cubit.dart';
import 'package:shamunity/logic/notification bloc/cubit/notification_state.dart';
import 'package:shamunity/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // جلب الإشعارات عند بدء الشاشة
    context.read<NotificationCubit>().fetchNotifications(refresh: true);
  }

  Future<void> _onRefresh() async {
    await context.read<NotificationCubit>().fetchNotifications(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError &&
              context.read<NotificationCubit>().notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ في تحميل الإشعارات',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<NotificationCubit>()
                        .fetchNotifications(refresh: true),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final notifications = context.read<NotificationCubit>().notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إشعارات',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ستظهر إشعاراتك هنا عند وصولها',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCardWidget(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // إضافة منطق التنقل حسب نوع الإشعار
    NotificationNavigationHelper.handleNotificationTap(context, notification);
    // يمكن إضافة المزيد من أنواع الإشعارات هنا
  }
}
