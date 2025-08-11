import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class EmptyData extends StatelessWidget {
  final String message;
  const EmptyData({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
            child: Lottie.asset('assets/images/empty.json',
                width: 400.w, height: 300.h)),
        Text(
          message,
          style: TextStyle(
            color: Colors.blue[600],
            fontSize: 16.sp,
          ),
        )
      ],
    );
  }
}
