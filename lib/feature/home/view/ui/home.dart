import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/feature/announcements/announcements_demo.dart';
import 'package:shamunity/feature/chat/user_group_srcreen.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/menua/menua_screen.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/feature/search/index.dart';
import 'package:shamunity/routes/extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              actions: [
                // أيقونة البحث
                IconButton(
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
                  child: const TabBar(
                    indicatorColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(icon: Icon(Icons.home, size: 30)),
                      Tab(icon: Icon(Icons.people_outline, size: 30)),
                      Tab(icon: Icon(Icons.notifications_active, size: 30)),
                      Tab(icon: Icon(Icons.menu_book_outlined, size: 30)),
                      Tab(icon: Icon(Icons.announcement, size: 30)),
                      Tab(icon: Icon(Icons.menu, size: 30)),
                    ],
                  ),
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
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

class LibraryBooksTab extends StatelessWidget {
  const LibraryBooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('المكتبة'));
  }
}
