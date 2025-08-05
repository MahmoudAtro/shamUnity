import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/feature/auth/login/widgets/dont_have_account.dart';
import 'package:shamunity/feature/auth/login/widgets/email_and_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 80.h),
                    Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w500,
                        color: ColorsManager.gold,
                      ),
                    ),
                    verticalspace(50),
                    verticalspace(20),
                    Form(key: formKey, child: const EmailAndPassword()),
                    verticalspace(30),
                    // زر تسجيل الدخول
                    _buildSubmitButton(),
                    SizedBox(height: 16.h),
                    const DontHaveAccount(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // خلفية الشاشة
  Widget _buildBackground() {
    return Column(
      children: [
        // الشريط الذهبي العلوي
        Container(
          height: 50.h,
          color: ColorsManager.gold,
        ),

        // المساحة البيضاء الوسطى
        Expanded(
          flex: 8,
          child: Container(
            color: Colors.white,
          ),
        ),

        // الشريط الأزرق السفلي
        Container(
          height: 50.h,
          color: ColorsManager.mainBlue,
        ),
      ],
    );
  }

  // زر تسجيل الدخول
  Widget _buildSubmitButton() {
    return AppTextButton(
      buttonText: "تسجيل الدخول",
      buttonHeight: 56,
      buttonWidth: 200,
      backgroundColor: ColorsManager.mainBlue,
      borderRadius: 24.r,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
      ),
      onPressed: () {
        if (formKey.currentState!.validate() && isChecked) {
          // تنفيذ عملية تسجيل الدخول
          print("تسجيل الدخول باستخدام:");
        }
      },
    );
  }
}
