import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/app_drop_down_form_feild.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';

class UniversityInfoForm extends StatefulWidget {
  const UniversityInfoForm({super.key});

  @override
  State<UniversityInfoForm> createState() => _UniversityInfoFormState();
}

class _UniversityInfoFormState extends State<UniversityInfoForm> {
  final TextEditingController universityIdController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController academicYearController = TextEditingController();

  // قوائم البيانات للقوائم المنسدلة
  final List<String> colleges = ['كلية الهندسة', 'كلية الطب', 'كلية العلوم', 'كلية الآداب', 'كلية الحقوق'];
  final List<String> majors = ['هندسة برمجيات', 'هندسة كهرباء', 'هندسة مدنية', 'علوم الحاسوب', 'نظم المعلومات'];
  final List<String> academicYears = ['السنة الأولى', 'السنة الثانية', 'السنة الثالثة', 'السنة الرابعة', 'السنة الخامسة'];

  // القيم المختارة
  String? selectedCollege;
  String? selectedMajor;
  String? selectedAcademicYear;

  @override
  void dispose() {
    universityIdController.dispose();
    collegeController.dispose();
    majorController.dispose();
    academicYearController.dispose();
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
          controller: universityIdController,
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
        AppDropdownFormField<String>(
          hintText: "اختر السنة الدراسية",
          borderRadius: 12.r,
          backgroundColor: Colors.white,
          value: selectedAcademicYear,
          items: academicYears.map((year) {
            return DropdownMenuItem<String>(
              value: year,
              child: Text(year),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedAcademicYear = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "يرجى اختيار السنة الدراسية";
            }
            return null;
          },
        ),
      ],
    );
  }
}