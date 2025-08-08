import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/theming/styles.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';

class EmailAndPassword extends StatefulWidget {
  const EmailAndPassword({super.key});

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildUsernameField(),
      _buildPasswordField(),
      verticalspace(5),
      GestureDetector(
        onTap: () {},
        child: Text(
          "نسيت كلمة المرور",
          style: TextStyles.font16form.copyWith(
            fontSize: 16.sp,
            color: ColorsManager.mainBlue
          ),
        ),
      )
    ]);
  }

  // حقل اسم المستخدم
  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, right: 16.w),
          child: Text(
            "البريد الالكتروني",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ),
        AppTextFormField(
          controller: usernameController,
          hintText: "",
          borderRadius: 24.r,
          suffixIcon: const Icon(
            Icons.email_outlined,
            color: Colors.grey,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "يرجى إدخال البريد الالكتروني";
            }
            return null;
          },
        ),
      ],
    );
  }

  // حقل كلمة المرور
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, right: 16.w),
          child: Text(
            "كلمة المرور",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ),
        AppTextFormField(
          controller: passwordController,
          hintText: "",
          isObscureText: true,
          borderRadius: 24.r,
          suffixIcon: const Icon(
            Icons.lock_outline,
            color: Colors.grey,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "يرجى إدخال كلمة المرور";
            }
            return null;
          },
        ),
      ],
    );
  }
}
