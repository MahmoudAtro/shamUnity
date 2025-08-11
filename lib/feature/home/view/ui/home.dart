import 'package:flutter/material.dart';
import 'package:shamunity/feature/chat/user_group_srcreen.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/menua/menua_screen.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
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
      length: 5,
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
                      Tab(icon: Icon(Icons.menu, size: 30)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      PostListScreen(),
                      const UsersGroupsScreen(),
                      const NotificationsScreen(),
                      const LibraryHomeScreen(),
                      const MenuScreen(),
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
