import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';

class AgreementForm extends StatefulWidget {
  const AgreementForm({super.key});

  @override
  State<AgreementForm> createState() => _AgreementFormState();
}

class _AgreementFormState extends State<AgreementForm> {
  bool acceptTerms = false;
  bool acceptEmail = false;
  File? _selectedImage;
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final picked =
                    await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _selectedImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final picked =
                    await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => _selectedImage = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

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
        verticalspace(30),
        Center(
          child: _buildSubmitButton(),
        ),
      ],
    );
  }

  // صورة الملف الشخصي
  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _selectedImage != null
            ? Container(
                width: 130.w,
                height: 130.h,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_selectedImage!),
                    )),
              )
            : Container(
                width: 130.w,
                height: 130.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 90.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
        GestureDetector(
          onTap: () {
            _pickImage();
          },
          child: Container(
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
            fontSize: 15.sp,
            color: Colors.white,
          ),
        ),
        Transform.scale(
          scale: 1.4, // قيمة المقياس، 1.5 أكبر 50% من الحجم الأصلي
          child: Checkbox(
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
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return AppTextButton(
      buttonText: "إنشاء حساب",
      buttonHeight: 50.h,
      buttonWidth: 150.w,
      backgroundColor: Colors.transparent,
      borderSide: Colors.white,
      borderRadius: 24.r,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      onPressed: () {
        // التحقق من صحة النموذج أولاً
        if (context.read<RegisterBloc>().formkey2.currentState!.validate()) {
          if (acceptEmail && acceptTerms) {
            context.read<RegisterBloc>().add(RegisterRequestEvent());
          } else {
            Toast().error(context, 'يجب الموافقة على الشروط والأحكام');
          }
        }
      },
    );
  }
}
