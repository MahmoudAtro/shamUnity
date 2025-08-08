import 'package:flutter/material.dart';
import 'package:shamunity/feature/chat/widget/chat_card_widget.dart';
import 'package:shamunity/models/chat_item_model.dart';

class UsersListWidget extends StatelessWidget {
  final List<ChatItemModel> users;

  const UsersListWidget({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (_, index) {
        return ChatCardWidget(
          chat: users[index],
          onTap: () {
            // التنقل إلى صفحة الدردشة مع المستخدم
          },
        );
      },
    );
  }
}
