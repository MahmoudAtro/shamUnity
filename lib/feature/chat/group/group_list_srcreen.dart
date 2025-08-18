import 'package:flutter/material.dart';
// import 'package:shamunity/feature/chat/widget/chat_card_widget.dart';
import 'package:shamunity/models/chat_item_model.dart';

class GroupsListWidget extends StatelessWidget {
  final List<ChatItemModel> groups;

  const GroupsListWidget({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (_, index) {
        return SizedBox();
        // return ChatCardWidget(
        //   chat: groups[index],
        //   onTap: () {
        //     // التنقل إلى صفحة الدردشة مع المجموعة
        //   },
        // );
      },
    );
  }
}
