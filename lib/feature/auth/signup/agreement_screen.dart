import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/custom_appbar.dart';
import 'package:shamunity/feature/auth/signup/widgets/agreement_form.dart';
import 'package:shamunity/feature/auth/signup/widgets/step_indicator.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
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
                      currentStep: 2, // الخطوة الثالثة: الموافقة والاستخدام
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity, // إضافة العرض الكامل
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                color: ColorsManager.darkerLight,
                child: Column(
                  children: [
                    verticalspace(25),
                    Form(
                        key: context.read<RegisterBloc>().formkey2,
                        child: const AgreementForm()),
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

}
