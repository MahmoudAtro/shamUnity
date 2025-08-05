import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/feature/auth/signup/widgets/agreement_form.dart';
import 'package:shamunity/feature/auth/signup/widgets/step_indicator.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity, // إضافة العرض الكامل
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/bacground_chat.png"),
                        fit: BoxFit.cover)),
                child: Column(
                  children: [
                    verticalspace(40),
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
                      currentStep: 2, // الخطوة الثالثة: الموافقة والاستخدام
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity, // إضافة العرض الكامل
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                color: ColorsManager.mainBlue,
                child: Column(
                  children: [
                    verticalspace(25),
                    Form(
                        key: formKey,
                        child: const AgreementForm()
                        ),
                    verticalspace(30),
                    Center(
                      child: _buildSubmitButton(),
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

  // زر الإرسال (Submit)
  Widget _buildSubmitButton() {
    return AppTextButton(
      buttonText: "إنشاء حساب",
      buttonHeight: 50.h,
      buttonWidth: 150.w,
      backgroundColor: Colors.transparent,
      borderSide: Colors.white,
      borderRadius: 24.r,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      onPressed: () {
        // التحقق من صحة النموذج أولاً
        if (formKey.currentState?.validate() ?? false) {}
      },
    );
  }
}
