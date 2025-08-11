import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/feature/auth/login/widgets/dont_have_account.dart';
import 'package:shamunity/feature/auth/login/widgets/email_and_password.dart';
import 'package:shamunity/logic/login%20bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginBloc loginBloc;

  @override
  void initState() {
    loginBloc = LoginBloc(getit());
    super.initState();
  }

  @override
  void dispose() {
    loginBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => loginBloc,
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
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                                 100.h - // الشريطين العلوي والسفلي
                                 MediaQuery.of(context).padding.top -
                                 MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // مساحة مرنة في الأعلى
                            const Flexible(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            
                            // عنوان تسجيل الدخول
                            Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                fontSize: 35.sp,
                                fontWeight: FontWeight.w500,
                                color: ColorsManager.gold,
                              ),
                            ),
                            
                            SizedBox(height: 40.h),
                            
                            // حقول الإدخال
                            const EmailAndPassword(),
                            
                            SizedBox(height: 16.h),
                            
                            // رابط إنشاء حساب
                            const DontHaveAccount(),
                            
                            // مساحة مرنة في الأسفل
                            const Flexible(
                              flex: 1,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // الشريط السفلي الثابت
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