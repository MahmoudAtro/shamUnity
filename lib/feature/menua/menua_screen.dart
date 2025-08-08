import 'package:flutter/material.dart';
import 'package:shamunity/feature/menua/widget/menua_card.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // كارد الملف الشخصي
          Card(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=5'),
              ),
              title: const Text('محمد الأحمد',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: const Text('طالب في جامعة دمشق'),
              onTap: () {
                context.pushNamed(RoutesNames.profile);
              },
            ),
          ),

          const SizedBox(height: 10),

          // كارد الإعدادات
          MenuCard(
            icon: Icons.settings,
            title: 'الإعدادات',
            iconColor: const Color.fromARGB(255, 52, 75, 94),
            onTap: () {
              // الانتقال إلى صفحة الإعدادات
            },
          ),

          const SizedBox(height: 10),

          // كارد تسجيل الخروج
          MenuCard(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            iconColor: const Color.fromARGB(255, 52, 75, 94),
            onTap: () {
              // تأكيد تسجيل الخروج
            },
          ),
        ],
      ),
    );
  }
}
