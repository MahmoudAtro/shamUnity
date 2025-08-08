import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
      decoration: const BoxDecoration(
        color: ColorsManager.gold,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStepItem("البيانات\nالشخصية", 0),
          _buildStepConnector(0, 1),
          _buildStepItem("البيانات\nالجامعية", 1),
          _buildStepConnector(1, 2),
          _buildStepItem("الموافقة\nوالاستخدام", 2),
        ],
      ),
    );
  }

  // بناء عنصر الخطوة
  Widget _buildStepItem(String title, int step) {
    bool isActive = currentStep >= step;

    return Column(
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: isActive
              ? const Icon(Icons.check, color: ColorsManager.gold, size: 14)
              : null,
        ),
        SizedBox(height: 5.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // بناء رابط بين الخطوات
  Widget _buildStepConnector(int fromStep, int toStep) {
    bool isActive = currentStep >= toStep;

    return Expanded(
      child: Container(
        height: 2.h,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
      ),
    );
  }
}
