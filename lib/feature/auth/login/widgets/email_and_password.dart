import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/theming/styles.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';
import 'package:shamunity/logic/login%20bloc/login_bloc.dart';
import 'package:shamunity/routes/extension.dart';

class EmailAndPassword extends StatefulWidget {
  const EmailAndPassword({super.key});

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  LoginBloc get bloc => BlocProvider.of(context);
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: loginFormKey,
      child: Column(children: [
        _buildUsernameField(),
        _buildPasswordField(),
        verticalspace(5),
        GestureDetector(
          onTap: () {
            context.pushNamed('/forget-password');
          },
          child: Text(
            "نسيت كلمة المرور",
            style: TextStyles.font16form
                .copyWith(fontSize: 16.sp, color: ColorsManager.mainBlue),
          ),
        ),
        verticalspace(30),
        // زر تسجيل الدخول
        _buildSubmitButton(),
      ]),
    );
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
          controller: email,
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
          controller: password,
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
        if (loginFormKey.currentState!.validate()) {
          bloc.add(
              LoginRequestEvent(email: email.text, password: password.text));
        }
      },
    );
  }
}
