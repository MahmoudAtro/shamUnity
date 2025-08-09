import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/logic/verification%20bloc/verification_bloc.dart';

class VerificationForm extends StatefulWidget {
  final String email;
  const VerificationForm({
    super.key,
    required this.email,
  });

  @override
  State<VerificationForm> createState() => _VerificationFormState();
}

class _VerificationFormState extends State<VerificationForm> {
  VerificationBloc get bloc => BlocProvider.of(context);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PIN input field
        Directionality(
          textDirection: TextDirection.ltr,
          child: Pinput(
            controller: bloc.verificationCode,
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
                border: Border.all(color: ColorsManager.btncolor, width: 2),
              ),
              textStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            onCompleted: (pin) {},
          ),
        ),

        SizedBox(height: 40.h),

        // Enter button
        AppTextButton(
          buttonText: "تأكيد",
          buttonHeight: 56,
          buttonWidth: 200,
          backgroundColor: ColorsManager.mainBlue,
          borderRadius: 24.r,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
          onPressed: () {
            bloc.add(VerifyCodeEvent(email: widget.email));
          },
        ),

        SizedBox(height: 50.h),

        // "Didn't receive code" text and button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'هل استلمت رمز التحقق؟',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            bloc.add(ResendCodeEvent(email: widget.email));
          },
          child: Text(
            'إعادة الارسال',
            style: TextStyle(
                fontSize: 16.sp,
                color: Colors.amber[700],
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
