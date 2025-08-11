import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';
import 'package:shamunity/logic/rest-password%20cubit/rest_password_cubit.dart';

class RestPassword extends StatefulWidget {
  const RestPassword({super.key});

  @override
  State<RestPassword> createState() => _RestPasswordState();
}

class _RestPasswordState extends State<RestPassword> {
  TextEditingController newPassword = TextEditingController();
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
    newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => restPasswordCubit,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50.h,
                  color: ColorsManager.gold,
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          "إعادة تعيين كلمة المرور",
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
                                Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 8.h, right: 16.w),
                                  child: Text(
                                    "كلمة المرور الجديدة",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                AppTextFormField(
                                  controller: newPassword,
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
                                verticalspace(30),
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
                                        restPasswordCubit
                                            .restPassword(newPassword.text);
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
      ),
    );
  }
}
