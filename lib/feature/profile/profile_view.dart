import 'package:flutter/material.dart';
import 'package:shamunity/feature/profile/widget/profile_widget.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserModel(
      id: "12345678",
      name: "م.محمد محمد علي",
      avatarUrl: "https://i.pravatar.cc/150?img=12",
      email: "ahmad@email.com",
      phone: "0999888777",
      university: "جامعة التكنولوجيا",
      academicYear: "السنة الثالثة",
    );

    final posts = [
      PostModel(
        userName: user.name,
        userAvatarUrl: user.avatarUrl,
        postTime: "منذ ساعة",
        postText: "يوم رائع في الجامعة!",
        postImageUrl: "https://picsum.photos/400/300",
      ),
      PostModel(
        userName: user.name,
        userAvatarUrl: user.avatarUrl,
        postTime: "منذ 3 ساعات",
        postText: "استعداد للامتحانات النهائية.",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ProfileWidget(user: user, posts: posts),
    );
  }
}
