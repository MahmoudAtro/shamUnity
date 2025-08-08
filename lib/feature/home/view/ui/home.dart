import 'package:flutter/material.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/feature/profile/profile_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.grey[200],
              elevation: 1,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Sham Unity',
                    style: TextStyle(
                      color: Colors.blue[800],
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
                  color: Colors.white,child: const TabBar(
                  indicatorColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.blue,
                  tabs: [
                    Tab(icon: Icon(Icons.home, size: 30)), 
                    Tab(icon: Icon(Icons.people_outline, size: 30)), 
                    Tab(icon: Icon(Icons.notifications_active, size: 30)), 
                    Tab(icon: Icon(Icons.menu_book_outlined, size: 30)), 
                    Tab(icon: Icon(Icons.menu, size: 30)), 
                  ],
                ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      PostListScreen(),
                      const MarketTab(),
                      const NotificationsTab(),
                      const LibraryHomeScreen(),
                      const ProfileScreen(),
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

class VideoTab extends StatelessWidget {
  const VideoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('الفيديوهات'));
  }
}

class MarketTab extends StatelessWidget {
  const MarketTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('السوق'));
  }
}

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('الإشعارات'));
  }
}

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('القائمة'));
  }
}

class LibraryBooksTab extends StatelessWidget {
  const LibraryBooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('المكتبة'));
  }
}
