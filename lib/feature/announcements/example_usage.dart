// مثال على كيفية دمج صفحة الإعلانات في التطبيق

import 'package:flutter/material.dart';
import 'package:shamunity/feature/announcements/announcements_demo.dart';
import 'package:shamunity/feature/announcements/index.dart';

// مثال 1: إضافة زر في القائمة الرئيسية
class MainMenuWithAnnouncements extends StatelessWidget {
  const MainMenuWithAnnouncements({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('القائمة الرئيسية')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.announcement, color: Colors.blue),
            title: const Text('قرارات الجامعة'),
            subtitle: const Text('عرض الإعلانات والقرارات المهمة'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementsDemo(),
                ),
              );
            },
          ),
          // ... باقي عناصر القائمة
        ],
      ),
    );
  }
}

// مثال 2: إضافة في BottomNavigationBar
class BottomNavWithAnnouncements extends StatefulWidget {
  const BottomNavWithAnnouncements({super.key});

  @override
  State<BottomNavWithAnnouncements> createState() =>
      _BottomNavWithAnnouncementsState();
}

class _BottomNavWithAnnouncementsState
    extends State<BottomNavWithAnnouncements> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AnnouncementsDemo(), // صفحة الإعلانات
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'القرارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
}

// مثال 3: إضافة في Drawer
class AppDrawerWithAnnouncements extends StatelessWidget {
  const AppDrawerWithAnnouncements({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'ShamUnity',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            onTap: () {
              Navigator.pop(context);
              // التنقل للصفحة الرئيسية
            },
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('قرارات الجامعة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementsDemo(),
                ),
              );
            },
          ),
          // ... باقي عناصر القائمة
        ],
      ),
    );
  }
}

// صفحات وهمية للتوضيح
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('الصفحة الرئيسية')));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('الملف الشخصي')));
}
