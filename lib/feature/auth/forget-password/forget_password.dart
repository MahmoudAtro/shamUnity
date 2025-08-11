import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';
import 'package:shamunity/logic/rest-password%20cubit/rest_password_cubit.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController email = TextEditingController();
  final forgetKey = GlobalKey<FormState>();
  late RestPasswordCubit restPasswordCubit;

  @override
  void initState() {
    restPasswordCubit = RestPasswordCubit(getit());
    super.initState();
  }

  @override
  void dispose() {
    restPasswordCubit.close();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => restPasswordCubit,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              // الشريط العلوي الثابت
              Container(
                height: 50.h,
                color: ColorsManager.gold,
              ),

              // المحتوى القابل للتمرير
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          100.h -
                          MediaQuery.of(context).padding.top,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),
                        Text(
                          "إعادة تعيين كلمة المرور",
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w500,
                            color: ColorsManager.gold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 50.h),

                        // النموذج
                        Form(
                          key: forgetKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // تسمية حقل البريد الإلكتروني
                              Padding(
                                padding:
                                    EdgeInsets.only(bottom: 8.h, right: 16.w),
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
                                  // إضافة تحقق من صحة البريد الإلكتروني (اختياري)
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return "يرجى إدخال بريد إلكتروني صحيح";
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 30.h),

                              // زر إعادة التعيين
                              Align(
                                alignment: Alignment.center,
                                child: AppTextButton(
                                  buttonText: "إعادة التعيين",
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
                                    if (forgetKey.currentState!.validate()) {
                                      // إخفاء الكيبورد قبل الإرسال
                                      FocusScope.of(context).unfocus();
                                      restPasswordCubit
                                          .restPassword(email.text);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 50.h,
                color: ColorsManager.mainBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
