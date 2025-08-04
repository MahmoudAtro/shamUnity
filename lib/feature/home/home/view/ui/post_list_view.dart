import 'package:flutter/material.dart';
import 'package:shamunity/feature/home/home/view/widget/post_widget.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/models/user_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class PostListScreen extends StatelessWidget {
  final List<PostModel> posts = [
    PostModel(
      userName: "محمد علي",
      userAvatarUrl: "https://i.pravatar.cc/150?img=3",
      postTime: "قبل ساعة",
      postText: "يوم جميل جداً 🌞",
      postImageUrl: "https://picsum.photos/500/300",
    ),
    PostModel(
      userName: "سارة إبراهيم",
      userAvatarUrl: "https://i.pravatar.cc/150?img=5",
      postTime: "قبل 3 ساعات",
      postText: "استمتعنا اليوم في الحديقة.",
      postImageUrl: null,
    ),
    // يمكنك إضافة المزيد من المنشورات...
  ];

  final user = UserModel(
    id: 'user_123',
    name: 'محمد علي',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    email: 'mohammad@example.com',
    phone: '+966500000000',
  );

  Widget buildCreatePostCard(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.pushNamed(RoutesNames.createPost, arguments: user);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/150?img=1"),
                  radius: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "إنشاء منشور جديد",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Icon(Icons.edit, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildCreatePostCard(context, user);
          }
          return PostWidget(post: posts[index - 1]);
        },
      ),
    );
  }
}
