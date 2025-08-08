import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/custom_appbar.dart';
import 'package:shamunity/feature/auth/verification-otp/widgets/verification_form.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsManager.moreLightGray,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CustomAppbar(title: ''),
              verticalspace(60),
              Text(
                'أدخل رمز التحقق المرسل إلى بريدك الالكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: ColorsManager.darkerLight,
                  fontWeight: FontWeight.w500,
                ),
              ),

              verticalspace(80),

              // Verification form
              const VerificationForm(),
            ],
          ),
        ),
      ),
    );
  }
}
