import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/helpers/space_helper.dart';

class AgreementForm extends StatefulWidget {
  const AgreementForm({super.key});

  @override
  State<AgreementForm> createState() => _AgreementFormState();
}

class _AgreementFormState extends State<AgreementForm> {
  bool acceptTerms = false;
  bool acceptEmail = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfileImage(),
        verticalspace(20),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.white,
        ),
        verticalspace(20),
        _buildTermsTitle(),
        verticalspace(15),
        _buildTermsText(),
        verticalspace(25),
        _buildCheckboxRow(
          "هل توافق على شروط الخدمة التالية؟",
          acceptTerms,
          (value) {
            setState(() {
              acceptTerms = value!;
            });
          },
        ),
        verticalspace(15),
        _buildCheckboxRow(
          "هل ترغب في استقبال رسائل بريدية؟",
          acceptEmail,
          (value) {
            setState(() {
              acceptEmail = value!;
            });
          },
        ),
      ],
    );
  }

  // صورة الملف الشخصي
  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120.w,
          height: 120.h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: 80.sp,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          width: 35.w,
          height: 35.h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // عنوان الشروط والأحكام
  Widget _buildTermsTitle() {
    return Text(
      "حقوق استخدام البرنامج والشروط",
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // نص الشروط والأحكام
  Widget _buildTermsText() {
    return Text(
      "- هذا البرنامج محمي بموجب قوانين حقوق النشر."
      " \n- لا يسمح لك بنسخ أو تعديل أو استخدامه لأغراض تجارية دون إذن."
      "\n- باستخدامك لهذا البرنامج، فإنك توافق على اتباع القواعد واحترام حقوق المطورين.",
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.white,
        height: 1.5,
      ),
      textAlign: TextAlign.right,
    );
  }

  // صف مربع الاختيار
  Widget _buildCheckboxRow(String text, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          checkColor: Colors.white,
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.green;
            }
            return Colors.white;
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }
}
