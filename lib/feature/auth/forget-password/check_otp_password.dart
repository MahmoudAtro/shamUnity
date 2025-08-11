import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/logic/rest-password%20cubit/rest_password_cubit.dart';

class CheckOtpPassword extends StatefulWidget {
  final String email;
  const CheckOtpPassword({super.key, required this.email});

  @override
  State<CheckOtpPassword> createState() => _CheckOtpPasswordState();
}

class _CheckOtpPasswordState extends State<CheckOtpPassword> {
  TextEditingController otp = TextEditingController();
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
    otp.dispose();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50.h,
                color: ColorsManager.gold,
              ),
              IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        "إرسال رمز التحقق",
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsManager.gold,
                        ),
                      ),
                      verticalspace(50),
                      Form(
                          key: forgetKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Pinput(
                                  controller: otp,
                                  length: 6,
                                  defaultPinTheme: PinTheme(
                                    width: 70.w,
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  focusedPinTheme: PinTheme(
                                    width: 50.w,
                                    height: 60.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                          color: ColorsManager.btncolor,
                                          width: 2),
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onCompleted: (pin) {},
                                ),
                              ),
                              verticalspace(30),
                              Align(
                                alignment: Alignment.center,
                                child: AppTextButton(
                                  buttonText: "تأكيد",
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
                                      restPasswordCubit.checkOtp(
                                        widget.email,
                                        otp.text,
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ))
                    ],
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
