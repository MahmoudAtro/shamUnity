import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/app_drop_down_form_feild.dart';
import 'package:shamunity/core/widgets/app_text_button.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';
import 'package:shamunity/core/widgets/drop_down_visit_result.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';
import 'package:shamunity/routes/extension.dart';

class UniversityInfoForm extends StatefulWidget {
  const UniversityInfoForm({super.key});

  @override
  State<UniversityInfoForm> createState() => _UniversityInfoFormState();
}

class _UniversityInfoFormState extends State<UniversityInfoForm>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController universityId = TextEditingController();
  final TextEditingController collage = TextEditingController();
  final TextEditingController major = TextEditingController();
  final TextEditingController year = TextEditingController();
  final formkey1 = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;

  // قوائم البيانات للقوائم المنسدلة
  final Map<String, List<String>> collegeMajorsMap = {
    'كلية الهندسة': [
      'هندسة معلوماتية',
      'هندسة مدنية',
      'هندسة ميكاترونكس',
      'هندسة اتصالات',
      'هندسة كيميائية',
      'هندسة زراعية',
    ],
    'كلية العلوم الصحية': [
      'قسم التمريض',
      'قسم الطوارئ',
      'قسم التخدير',
    ],
    'كلية الاداب والعلوم الإنسانية': [
      'قسم اللغة الانكليزية',
      'قسم اللغة العربية',
    ],
    'كلية الشريعة والقانون': [],
    'كلية التربية': [
      'معلم صف',
      'ارشاد نفسي',
      'رياض اطفال',
    ],
    'كلية الاقتصاد والادارة': [],
    'كلية العلوم السياسية': []
  };

  final Map<int, String> academicYearsMap = {
    1: 'السنة الأولى',
    2: 'السنة الثانية',
    3: 'السنة الثالثة',
    4: 'السنة الرابعة',
  };

  // القيم المختارة
  String? selectedCollege;
  String? selectedMajor;
  int? selectedAcademicYear;
  List<String> majorsList = [];

  @override
  void initState() {
    universityId.text =
        context.read<RegisterBloc>().registrationData['university_id'];
    collage.text = context.read<RegisterBloc>().registrationData['collage'];
    major.text = context.read<RegisterBloc>().registrationData['major'];
    year.text = context.read<RegisterBloc>().registrationData['academic_year'].toString();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromControllers();
    });
  }

  void _initializeFromControllers() {
    // تهيئة الكلية
    if (collage.text.isNotEmpty) {
      selectedCollege = collage.text;
      majorsList = collegeMajorsMap[selectedCollege] ?? [];
    }

    // تهيئة التخصص
    if (major.text.isNotEmpty) {
      selectedMajor = major.text;
    }

    // تهيئة السنة الدراسية
    if (year.text.isNotEmpty) {
      selectedAcademicYear = int.tryParse(year.text);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
        verticalspace(30),
        // زر التالي
        Center(
          child: _buildNextButton(),
        ),
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
          controller: universityId,
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

  // زر التالي
  Widget _buildNextButton() {
    return AppTextButton(
      buttonText: "التالي",
      buttonHeight: 50,
      buttonWidth: 120,
      backgroundColor: Colors.transparent,
      borderSide: Colors.white,
      borderRadius: 24.r,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      onPressed: () {
        if (formkey1.currentState!.validate()) {
          context.read<RegisterBloc>().registrationData['university_id'] =
              universityId.text;
          context.read<RegisterBloc>().registrationData['collage'] =
              collage.text;
          context.read<RegisterBloc>().registrationData['major'] = major.text;
          context.read<RegisterBloc>().registrationData['academic_year'] =
              year.text;
          context.pushNamed("/agreement");
        }
      },
    );
  }

  // قائمة الكليات المنسدلة
  Widget _buildCollegeDropdown() {
    return Form(
      key: formkey1,
      child: Column(
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
          DropDownVisitResult<String>(
            key: ValueKey('college_dropdown_${selectedCollege ?? 'empty'}'),
            hintText: "اختر الكلية",
            controller: collage,
            borderRadius: 12.r,
            backgroundColor: Colors.white,
            value: selectedCollege,
            items: collegeMajorsMap.keys
                .map((college) => DropdownMenuItem(
                      value: college,
                      child: Text(college),
                    ))
                .toList(),
            onChanged: (value) {
              _handleCollegeChange(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "يرجى اختيار الكلية";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // معالجة تغيير الكلية
  void _handleCollegeChange(String? value) {
    if (selectedCollege != value) {
      setState(() {
        selectedCollege = value;
        // إعادة تعيين التخصص والسنة
        selectedMajor = null;
        selectedAcademicYear = null;

        // تحديث قائمة التخصصات
        majorsList = collegeMajorsMap[value] ?? [];

        // تحديث الـ controllers
        collage.text = value ?? '';
        major.text = '';
        year.text = '';
      });
    }
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
        DropDownVisitResult<String>(
          key: ValueKey(
              'major_dropdown_${selectedCollege ?? 'empty'}_${selectedMajor ?? 'empty'}'),
          hintText: majorsList.isEmpty ? "اختر الكلية أولاً" : "اختر التخصص",
          controller: major,
          borderRadius: 12.r,
          backgroundColor: Colors.white,
          value: selectedMajor,
          items: majorsList
              .map((major) => DropdownMenuItem(
                    value: major,
                    child: Text(major),
                  ))
              .toList(),
          onChanged: majorsList.isNotEmpty
              ? (value) {
                  setState(() {
                    selectedMajor = value;
                    selectedAcademicYear = null; // إعادة تعيين السنة
                    major.text = value ?? '';
                    year.text = '';
                  });
                }
              : (value) {},
          validator: (value) {
            if (majorsList.isNotEmpty && (value == null || value.isEmpty)) {
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
          hintText: selectedMajor == null
              ? "اختر التخصص أولاً"
              : "اختر السنة الدراسية",
          controller: year,
          borderRadius: 12.r,
          backgroundColor: Colors.white,
          value: selectedAcademicYear,
          items: selectedMajor != null
              ? academicYearsMap.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList()
              : [],
          onChanged: selectedMajor != null
              ? (value) {
                  setState(() {
                    selectedAcademicYear = value;
                    year.text = value?.toString() ?? '';
                  });
                }
              : (value) {},
          validator: (value) {
            if (selectedMajor != null && value == null) {
              return "يرجى اختيار السنة الدراسية";
            }
            return null;
          },
        ),
      ],
    );
  }
}
