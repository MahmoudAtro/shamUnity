import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/routes/extension.dart';

class DontHaveAccount extends StatelessWidget {
  const DontHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "ليس لديك حساب؟",
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: () {
            context.pushNamed('/signup');
          },
          child: Text(
            " إنشاء حساب",
            style: TextStyle(
              fontSize: 15.sp,
              color: ColorsManager.gold,
            ),
          ),
        ),
      ],
    );
  }
}
