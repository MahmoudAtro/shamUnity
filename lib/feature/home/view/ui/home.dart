import 'package:flutter/material.dart';
import 'package:shamunity/feature/chat/user_group_srcreen.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/menua/menua_screen.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';
import 'package:shamunity/feature/post/post_list_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
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
                color: Colors.white,
                child: const TabBar(
                  indicatorColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.blue,
                  tabs: [
                    Tab(icon: Icon(Icons.home, size: 30)),
                    Tab(icon: Icon(Icons.chat, size: 30)),
                    Tab(icon: Icon(Icons.library_books, size: 30)),
                    Tab(icon: Icon(Icons.notifications_active, size: 30)),
                    Tab(icon: Icon(Icons.menu, size: 30)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    PostListScreen(),
                    UsersGroupsScreen(),
                    LibraryHomeScreen(),
                    NotificationsScreen(),
                    MenuScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
