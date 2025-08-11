import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/feature/auth/verification-otp/widgets/verification_form.dart';
import 'package:shamunity/logic/verification%20bloc/verification_bloc.dart';
import 'package:shamunity/routes/extension.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  const VerificationCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  late VerificationBloc _verificationBloc;
  @override
  void initState() {
    _verificationBloc = VerificationBloc(getit());
    super.initState();
  }

  @override
  void dispose() {
    _verificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: ColorsManager.moreLightGray,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      onPressed: () {
                        context.pushNamedAndRemoveUntil('/enterPlatform',
                            predicate: (route) => false);
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                      )),
                ),
                verticalspace(60),
                Text(
                  'أدخل رمز التحقق المرسل إلى بريدك الالكتروني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: ColorsManager.darkerLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                verticalspace(80),

                // Verification form
                BlocProvider.value(
                  value: _verificationBloc,
                  child: VerificationForm(email: widget.email),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
