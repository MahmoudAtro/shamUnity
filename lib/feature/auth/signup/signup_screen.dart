import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/core/widgets/custom_appbar.dart';
import 'package:shamunity/feature/auth/signup/widgets/signup_form.dart';
import 'package:shamunity/feature/auth/signup/widgets/step_indicator.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';
import 'package:shamunity/routes/extension.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/bacground_chat.png"),
                        fit: BoxFit.cover)),
                child: Column(
                  children: [
                    const CustomAppbar(title: ""),
                    Center(
                      child: Text(
                        "إنشاء حساب",
                        style: TextStyle(
                          fontSize: 35.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsManager.gold,
                        ),
                      ),
                    ),
                    verticalspace(30),
                    const StepIndicator(
                      currentStep: 0,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                color: ColorsManager.darkerLight,
                child: Column(
                  children: [
                    verticalspace(25),
                    Form(
                        key: context.read<RegisterBloc>().formkey,
                        child: const SignupForm()),
                    verticalspace(30),
                    // زر التالي
                    Center(
                      child: _buildNextButton(),
                    ),
                    verticalspace(20),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // زر التالي
  Widget _buildNextButton() {
    return AppTextButton(
      buttonText: "التالي",
      buttonHeight: 50,
      buttonWidth: 120,
      backgroundColor: Colors.transparent,
      borderSide: Colors.white,
      borderRadius: 24.r,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      onPressed: () {
        if (context.read<RegisterBloc>().formkey.currentState!.validate()) {
          context.pushNamed("/university-info",
              arguments: BlocProvider.of<RegisterBloc>(context));
        }
      },
    );
  }
}
