import 'package:flutter/material.dart';
import 'package:shamunity/feature/chat/group/group_list_srcreen.dart';
import 'package:shamunity/feature/chat/user/user_list_srcreen.dart';
import 'package:shamunity/models/chat_item_model.dart';

class UsersGroupsScreen extends StatefulWidget {
  const UsersGroupsScreen({super.key});

  @override
  State<UsersGroupsScreen> createState() => _UsersGroupsScreenState();
}

class _UsersGroupsScreenState extends State<UsersGroupsScreen> {
  @override
  Widget build(BuildContext context) {
    final List<ChatItemModel> dummyUsers = [
      ChatItemModel(
        id: '1',
        name: 'أحمد',
        imageUrl: 'https://i.pravatar.cc/100?img=1',
        lastMessage: 'مرحبا، كيف الحال؟',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatItemModel(
        id: '2',
        name: 'سارة',
        imageUrl: 'https://i.pravatar.cc/100?img=2',
        lastMessage: 'شكراً للتواصل.',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    final List<ChatItemModel> dummyGroups = [
      ChatItemModel(
        id: 'g1',
        name: 'مجموعة الرياضيات',
        imageUrl: 'https://via.placeholder.com/100x100.png?text=Math',
        lastMessage: 'بدأنا الدرس الجديد اليوم.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: Column(
              children: [
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                tabController.animateTo(0);
                              });
                            },
                            child: Column(
                              children: [
                                const Text("المستخدمين",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                if (tabController.index == 0)
                                  const SizedBox(height: 4),
                                if (tabController.index == 0)
                                  Container(
                                      height: 3, color: Colors.blue, width: 50),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                tabController.animateTo(1);
                              });
                            },
                            child: Column(
                              children: [
                                const Text("المجموعات",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                if (tabController.index == 1)
                                  const SizedBox(height: 4),
                                if (tabController.index == 1)
                                  Container(
                                      height: 3, color: Colors.blue, width: 50),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      UsersListWidget(users: dummyUsers),
                      GroupsListWidget(groups: dummyGroups),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
