import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
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
  bool isChecked = false;

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
          body: Stack(
            children: [
              _buildBackground(),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 80.h),
                      Text(
                        "تسجيل الدخول",
                        style: TextStyle(
                          fontSize: 35.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsManager.gold,
                        ),
                      ),
                      verticalspace(50),
                      verticalspace(20),
                      const EmailAndPassword(),
                      SizedBox(height: 16.h),
                      const DontHaveAccount(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBackground() {
    return Column(
      children: [
        // الشريط الذهبي العلوي
        Container(
          height: 50.h,
          color: ColorsManager.gold,
        ),

        // المساحة البيضاء الوسطى
        Expanded(
          flex: 8,
          child: Container(
            color: Colors.white,
          ),
        ),

        // الشريط الأزرق السفلي
        Container(
          height: 50.h,
          color: ColorsManager.mainBlue,
        ),
      ],
    );
  }
}
