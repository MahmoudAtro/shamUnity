import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/app_drop_down_form_feild.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';

class UniversityInfoForm extends StatefulWidget {
  const UniversityInfoForm({super.key});

  @override
  State<UniversityInfoForm> createState() => _UniversityInfoFormState();
}

class _UniversityInfoFormState extends State<UniversityInfoForm> {
  // قوائم البيانات للقوائم المنسدلة
  final List<String> colleges = [
    'كلية الهندسة',
    'كلية الطب',
    'كلية العلوم',
    'كلية الآداب',
    'كلية الحقوق'
  ];
  final List<String> majors = [
    'هندسة برمجيات',
    'هندسة كهرباء',
    'هندسة مدنية',
    'علوم الحاسوب',
    'نظم المعلومات'
  ];
  final Map<int, String> academicYearsMap = {
    1: 'السنة الأولى',
    2: 'السنة الثانية',
    3: 'السنة الثالثة',
    4: 'السنة الرابعة',
    5: 'السنة الخامسة',
  };
  int? selectedAcademicYear;

  // القيم المختارة
  String? selectedCollege;
  String? selectedMajor;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUniversityIdField(),
        verticalspace(20),
        _buildCollegeDropdown(),
        verticalspace(20),
        _buildMajorDropdown(),
        verticalspace(20),
        _buildAcademicYearDropdown(),
      ],
    );
  }

  // حقل رقم الجامعة
  Widget _buildUniversityIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "الرقم الجامعي",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        AppTextFormField(
          controller: context.read<RegisterBloc>().universityId,
          hintText: "",
          borderRadius: 12.r,
          backgroundColor: Colors.white,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "يرجى إدخال رقم الجامعة";
            }
            return null;
          },
        ),
      ],
    );
  }

  // قائمة الكليات المنسدلة
  Widget _buildCollegeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "الكلية",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        AppDropdownFormField<String>(
          hintText: "اختر الكلية",
          controller: context.read<RegisterBloc>().collage,
          borderRadius: 12.r,
          backgroundColor: Colors.white,
          value: selectedCollege,
          items: colleges.map((college) {
            return DropdownMenuItem<String>(
              value: college,
              child: Text(college),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCollege = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "يرجى اختيار الكلية";
            }
            return null;
          },
        ),
      ],
    );
  }

  // قائمة التخصصات المنسدلة
  Widget _buildMajorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "الاختصاص الجامعي",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        AppDropdownFormField<String>(
          hintText: "اختر التخصص",
          controller: context.read<RegisterBloc>().major,
          borderRadius: 12.r,
          backgroundColor: Colors.white,
          value: selectedMajor,
          items: majors.map((major) {
            return DropdownMenuItem<String>(
              value: major,
              child: Text(major),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedMajor = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "يرجى اختيار التخصص";
            }
            return null;
          },
        ),
      ],
    );
  }

  // قائمة السنوات الدراسية المنسدلة
  Widget _buildAcademicYearDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "السنة الدراسية",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        AppDropdownFormField<int>(
          hintText: "اختر السنة الدراسية",
          controller: context.read<RegisterBloc>().year,
          borderRadius: 12.r,
          backgroundColor: Colors.white,
          value: selectedAcademicYear,
          items: academicYearsMap.entries.map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedAcademicYear = value;
              // خزّن النص الرقمي في الـ Bloc controller كنص (أو عدل نوعه)
              context.read<RegisterBloc>().year.text = value?.toString() ?? '';
            });
          },
          validator: (value) {
            if (value == null) {
              return "يرجى اختيار السنة الدراسية";
            }
            return null;
          },
        ),
      ],
    );
  }
}
