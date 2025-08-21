import 'package:flutter/material.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/core/theming/styles.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/feature/menua/widget/menua_card.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Card(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: user?.profilePictureUrl != null
                    ? NetworkImage(
                        "${ApiConstances.baseUrlImg}${user!.profilePictureUrl!}")
                    : const AssetImage('assets/images/default_avatar.jpg'),
              ),
              title: Text("${user?.firstName} ${user?.lastName}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(user?.college ?? ''),
              onTap: () {
                context.pushNamed(RoutesNames.profile);
              },
            ),
          ),
          const SizedBox(height: 10),
          MenuCard(
            icon: Icons.settings,
            title: 'الإعدادات',
            iconColor: const Color.fromARGB(255, 52, 75, 94),
            onTap: () {},
          ),
          MenuCard(
            icon: Icons.support_agent,
            title: 'الإقتراحات',
            iconColor: const Color.fromARGB(255, 52, 75, 94),
            onTap: () {
              context.pushNamed('/suggesation');
            },
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: AppTextButton(
              buttonText: 'تسجيل الخروج',
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              backgroundColor: Colors.red,
              borderRadius: 12,
              buttonHeight: 55,
              onPressed: () {
                logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  logout(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.logout,
          color: Colors.red,
          size: 32,
        ),
        content: Text(
          textAlign: TextAlign.center,
          "هل انت متاكد من تسجيل الخروج ؟",
          style: TextStyles.font15homefooter.copyWith(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(
              'الغاء',
              style: TextStyles.font14DarkBlueMedium,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              context.pushNamedAndRemoveUntil('/enterPlatform',
                  predicate: (route) => false);
              await SecureSharedPrefHelper.logout();
            },
            icon: const Icon(Icons.logout, size: 18, color: Colors.white),
            label: Text(
              'تسجيل الخروج',
              style: TextStyles.font14Medium.copyWith(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
