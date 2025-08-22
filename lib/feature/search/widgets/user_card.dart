import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/routes/extension.dart';

class UserCard extends StatelessWidget {
  final Author user;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onTap ??
            () {
              // التنقل إلى صفحة الملف الشخصي للمستخدم
              context.pushNamed('/profile', arguments: user.id);
            },
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          radius: 25.r,
          backgroundImage: user.profilePictureUrl != null
              ? NetworkImage("${ApiConstances.baseUrlImg}${user.profilePictureUrl!}")
              : const AssetImage('assets/images/default_avatar.jpg')
                  as ImageProvider,
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: ColorsManager.mainBlue,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.college != null) ...[
              SizedBox(height: 2.h),
              Text(
                user.college!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (user.major != null) ...[
              SizedBox(height: 2.h),
              Text(
                user.major!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
