import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/apis/notification/api_notification.dart';
import 'package:shamunity/core/network/dio_factory.dart';
import 'package:shamunity/feature/announcements/announcements_demo.dart';
import 'package:shamunity/feature/chat/user_group_srcreen.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/menua/menua_screen.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/feature/search/search_screen.dart';
import 'package:shamunity/logic/notification bloc/cubit/notification_cubit.dart';
import 'package:shamunity/routes/extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.currentIndex, this.isVisited = false});
  final int? currentIndex;
  final bool isVisited;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotificationCubit notificationCubit;
  @override
  void initState() {
    notificationCubit = context.read<NotificationCubit>();
    super.initState();
    // عدد التابات عندك = 6
    _tabController = widget.isVisited
        ? TabController(length: 2, vsync: this)
        : TabController(length: 6, vsync: this);

    if (widget.currentIndex != null) {
      goToTab(widget.currentIndex!);
    }
    _tabController.addListener(_onTabChanged);
  }

  void goToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 4) {
      // تاب الإشعارات
      notificationCubit.cleanUnreadCount(); // تصفير العداد
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) {
          final cubit = NotificationCubit(
            notificationApi: ApiNotification(dio: DioFactory.getDio()),
          );
          // جلب الإشعارات عند بدء التطبيق
          cubit.fetchNotifications(refresh: true);
          return cubit;
        },
        child: DefaultTabController(
          length: widget.isVisited ? 2 : 6,
          child: SafeArea(
            child: WillPopScope(
              onWillPop: () async => false,
              child: Scaffold(
                // ...existing code...
                floatingActionButton: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 16),
                    child: FloatingActionButton(
                      heroTag: 'home_gemini_chat_button', // إضافة hero tag فريد
                      backgroundColor: Colors.blueAccent,
                      elevation: 4,
                      onPressed: () {
                        context.pushNamed('/geminiChat');
                      },
                      child: Image.asset(
                        'assets/images/shamai.png',
                        width: 36,
                        height: 36,
                      ),
                    ),
                  ),
                ),
                backgroundColor: Colors.grey[100],
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.blueAccent,
                  elevation: 1,
                  leading: widget.isVisited
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                        ),
                  actions: [
                    // أيقونة البحث
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                      child: const Text(
                        'ShamUnity',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: -1.5,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        labelColor: Colors.blue,
                        tabs: widget.isVisited
                            ? const [
                                Tab(icon: Icon(Icons.home, size: 30)),
                                Tab(icon: Icon(Icons.article, size: 30)),
                              ]
                            : [
                                const Tab(icon: Icon(Icons.home, size: 30)),
                                const Tab(
                                    icon: Icon(Icons.people_outline, size: 30)),
                                const Tab(
                                    icon: Icon(Icons.menu_book_outlined,
                                        size: 30)),
                                const Tab(icon: Icon(Icons.article, size: 30)),
                                Tab(
                                  icon: Stack(
                                    children: [
                                      const Icon(Icons.notifications_active,
                                          size: 30),
                                      if (notificationCubit.unreadCount > 0)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Text(
                                              notificationCubit.unreadCount > 99
                                                  ? '99+'
                                                  : '${notificationCubit.unreadCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Tab(icon: Icon(Icons.menu, size: 30)),
                              ],
                      ),
                    ),
                    widget.isVisited
                        ? Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: const [
                                PostListScreen(
                                  isVisited: true,
                                ),
                                AnnouncementsDemo(),
                              ],
                            ),
                          )
                        : Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                PostListScreen(),
                                UsersGroupsScreen(),
                                LibraryHomeScreen(),
                                AnnouncementsDemo(),
                                const NotificationsScreen(),
                                MenuScreen(),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
