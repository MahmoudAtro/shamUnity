import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/theming/styles.dart';


class AppTextFormField extends StatelessWidget {
  final TextInputType? keyboardType;
  final int? maxLines;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final String hintText;
  final bool? isObscureText;
  final bool? readOnly;
  final Widget? suffixIcon;
  final TextDirection? hintTextDirection;
  final TextDirection? textDirection;
  final Color? backgroundColor;
  final double? borderRadius;
  final TextEditingController? controller;
  final Function(String?) validator;
  final Function(String?)? onFieldSubmitted;
  final void Function(String)? onChanged;

  const AppTextFormField({
    super.key,
    this.maxLines,
    this.keyboardType,
    this.suffix,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.inputTextStyle,
    this.hintStyle,
    required this.hintText,
    this.isObscureText,
    this.suffixIcon,
    this.backgroundColor,
    this.controller,
    required this.validator,
    this.prefixIcon,
    this.borderRadius,this.readOnly,
    this.hintTextDirection,
    this.textDirection,
    this.onFieldSubmitted,
    this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      readOnly: readOnly ?? false,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      decoration: InputDecoration(
        suffix: suffix,
        isDense: true,
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        focusedBorder: focusedBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(
                color: ColorsManager.mainBlue,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
            ),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(
                color: ColorsManager.lighterGray,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
            ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        hintStyle: hintStyle ?? TextStyles.font14LightGrayRegularForm,
        hintText: hintText,
        hintTextDirection: hintTextDirection ?? TextDirection.rtl,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        fillColor: isDarkMode
            ? Colors.grey[900]
            : backgroundColor ?? ColorsManager.moreLightGray,
        filled: true,
      ),
      onFieldSubmitted: onFieldSubmitted,
      obscureText: isObscureText ?? false,
      textDirection: textDirection ?? TextDirection.ltr,
      style: isDarkMode
          ? TextStyles.font14DarkBlueMedium.copyWith(color: Colors.white)
          : TextStyles.font14DarkBlueMedium,
      validator: (value) {
        return validator(value);
      },
      onChanged: onChanged,
    );
  }
}
