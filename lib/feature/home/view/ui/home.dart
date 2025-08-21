import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/feature/announcements/announcements_demo.dart';
import 'package:shamunity/feature/chat/user_group_srcreen.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/menua/menua_screen.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/feature/search/search_screen.dart';
import 'package:shamunity/routes/extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.currentIndex});
  final int? currentIndex;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    // عدد التابات عندك = 6
    _tabController = TabController(length: 6, vsync: this);
    if (widget.currentIndex != null) {
      goToTab(widget.currentIndex!);
    }
  }

  void goToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            // ...existing code...
            floatingActionButton: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
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
              leading: IconButton(
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
                      color: ColorsManager.lightClor,
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
                    tabs: const [
                      Tab(icon: Icon(Icons.home, size: 30)),
                      Tab(icon: Icon(Icons.people_outline, size: 30)),
                      Tab(icon: Icon(Icons.notifications_active, size: 30)),
                      Tab(icon: Icon(Icons.menu_book_outlined, size: 30)),
                      Tab(icon: Icon(Icons.announcement, size: 30)),
                      Tab(icon: Icon(Icons.menu, size: 30)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      PostListScreen(),
                      UsersGroupsScreen(),
                      NotificationsScreen(),
                      LibraryHomeScreen(),
                      AnnouncementsDemo(),
                      MenuScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
