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
  final String email;
  final String token;
  const RestPassword({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<RestPassword> createState() => _RestPasswordState();
}

class _RestPasswordState extends State<RestPassword> {
  TextEditingController password = TextEditingController();
  final forgetKey = GlobalKey<FormState>();
  late RestPasswordCubit restPasswordCubit;
  bool isObscureText = true;

  @override
  void initState() {
    restPasswordCubit = RestPasswordCubit(getit());
    super.initState();
  }

  @override
  void dispose() {
    restPasswordCubit.close();
    password.dispose();
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
                                controller: password,
                                isObscureText: isObscureText,
                                hintText: "",
                                borderRadius: 24.r,
                                suffixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey,
                                ),
                                prefixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isObscureText = !isObscureText;
                                      });
                                    },
                                    icon: isObscureText
                                        ? const Icon(Icons.visibility_off,
                                            color: ColorsManager.gold)
                                        : const Icon(Icons.visibility,
                                            color: ColorsManager.gold)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "يرجى إدخال كلمة المرور الجديدة";
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
                                      restPasswordCubit.newPassword(
                                        widget.email,
                                        widget.token,
                                        password.text,
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
