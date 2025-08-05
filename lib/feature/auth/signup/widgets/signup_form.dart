import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/core/widgets/app_text_form_feild.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  DateTime? selectedDate;

  String selectedGender = 'male';

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    birthDateController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // محاذاة للعربية
      children: [
        _buildFormField("الاسم الأول", firstNameController),
        verticalspace(15),
        _buildFormField("الاسم الأخير", lastNameController),
        verticalspace(15),
        verticalspace(15),
        _buildGenderSelection(),
        verticalspace(15),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: _buildFormField(
              "تاريخ الميلاد",
              birthDateController,
              suffixIcon: const Icon(Icons.calendar_today,
                  color: Colors.white, size: 20),
              hintText: "اليوم / الشهر / السنة",
              readOnly: true, // جعل الحقل للقراءة فقط لمنع الإدخال اليدوي
            ),
          ),
        ),
        verticalspace(25),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.white,
        ),
        verticalspace(25),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // محاذاة البريد وكلمة المرور من اليسار
          children: [
            _buildFormField("البريد الإلكتروني", emailController),
            verticalspace(15),
            _buildFormField(
              "كلمة المرور",
              passwordController,
              isObscureText: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.visibility_outlined,
                    color: Colors.white, size: 20),
                onPressed: () {
                  // Toggle password visibility
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // بناء حقل النموذج العام
  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    bool isObscureText = false,
    Widget? suffixIcon,
    String? hintText,
    bool? readOnly,
  }) {
    // التحقق إذا كان الحقل للبريد الإلكتروني أو كلمة المرور
    bool isEmailOrPassword =
        label == "البريد الإلكتروني" || label == "كلمة المرور";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        AppTextFormField(
          controller: controller,
          hintText: hintText ?? "",
          isObscureText: isObscureText,
          borderRadius: 12.r,
          backgroundColor: Colors.white,
          suffixIcon: suffixIcon,
          readOnly: readOnly,
          hintTextDirection:
              isEmailOrPassword ? TextDirection.ltr : TextDirection.rtl,
          // تعيين اتجاه إدخال النص
          textDirection:
              isEmailOrPassword ? TextDirection.ltr : TextDirection.rtl,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "هذا الحقل مطلوب";
            }
            if (label == "البريد الإلكتروني" && !_isValidEmail(value)) {
              return "يرجى إدخال بريد إلكتروني صحيح";
            }
            if (label == "كلمة المرور" && value.length < 6) {
              return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
            }
            return null;
          },
        ),
      ],
    );
  }

  // بناء اختيار الجنس
  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "الجنس",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildGenderOption('female', 'أنثى'),
            SizedBox(width: 30.w),
            _buildGenderOption('male', 'ذكر'),
          ],
        ),
      ],
    );
  }

  // بناء خيار الجنس
  Widget _buildGenderOption(String value, String label) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedGender,
          activeColor: Colors.white,
          fillColor: WidgetStateProperty.all(Colors.white),
          onChanged: (newValue) {},
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

// اختيار التاريخ - استخدام الطريقة التقليدية بدلاً من المكتبة التي قد تسبب مشاكل
  void _selectDate(BuildContext context) {
    // استخدام showDatePicker المدمج في Flutter
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              // primary: ColorsManager.mainBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              // onSurface: ColorsManager.mainBlue,
            ),
          ),
          child: child!,
        );
      },
    ).then((picked) {
      if (picked != null) {
        setState(() {
          birthDateController.text = 
              "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
        });
      }
    });
  }

  // التحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}