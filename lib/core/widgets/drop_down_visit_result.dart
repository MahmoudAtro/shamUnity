import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/theming/styles.dart';

class DropDownVisitResult<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final Function(T?) onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final String hintText;
  final bool? isDense;
  final Color? backgroundColor;
  final double? borderRadius;
  final Function(T?) validator;
  final TextEditingController? controller;

  const DropDownVisitResult({
    super.key,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.value,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.inputTextStyle,
    this.hintStyle,
    this.prefixIcon,
    this.isDense,
    this.backgroundColor,
    this.borderRadius,
    required this.validator,
    this.controller,
  });

  @override
  _DropDownVisitResultState<T> createState() => _DropDownVisitResultState<T>();
}

class _DropDownVisitResultState<T> extends State<DropDownVisitResult<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value;
    if (widget.controller != null && selectedValue != null) {
      widget.controller!.text = selectedValue.toString();
    }
  }

  @override
  void didUpdateWidget(covariant DropDownVisitResult<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      if (selectedValue != null &&
          !isValueInItems(selectedValue, widget.items)) {
        setState(() {
          selectedValue = null;
          if (widget.controller != null) {
            widget.controller!.text = ''; // تعيين نص فارغ بدلاً من clear()
          }
          widget.onChanged(null);
        });
      }
    }
  }

  bool isValueInItems(T? value, List<DropdownMenuItem<T>> items) {
    return items.any((item) => item.value == value);
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<T>(
      value: selectedValue,
      items: widget.items,
      onChanged: (value) {
        setState(() {
          selectedValue = value;
          if (widget.controller != null) {
            widget.controller!.text = value != null ? value.toString() : '';
          }
        });
        widget.onChanged(value);
      },
      decoration: InputDecoration(
        isDense: widget.isDense ?? true,
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        focusedBorder: widget.focusedBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(
                color: ColorsManager.mainBlue,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
            ),
        enabledBorder: widget.enabledBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(
                color: ColorsManager.lighterGray,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
            ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        ),
        hintStyle: widget.hintStyle ?? TextStyles.font14LightGrayRegularForm,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        fillColor: isDarkMode
            ? Colors.grey[900]
            : widget.backgroundColor ?? ColorsManager.moreLightGray,
        filled: true,
      ),
      style: isDarkMode
          ? TextStyles.font14DarkBlueMedium.copyWith(color: Colors.grey)
          : TextStyles.font14DarkBlueMedium,
      validator: (value) => widget.validator(value),
    );
  }
}
