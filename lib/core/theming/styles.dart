import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/constants/font_weight_helper.dart';

class TextStyles {
  static TextStyle font14LightGrayRegular = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: Colors.white,
    fontFamily: "appfont",
  );

  static TextStyle font14LightGrayRegularForm = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: const Color(0xffB5B5B5),
    fontFamily: "appfont",
  );

  static TextStyle font14DarkBlueMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.darkBlue,
  );

  static TextStyle font14Medium = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.medium,
    color: Colors.white
  );

  static TextStyle font24BlackRegular = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeightHelper.regular,
    fontFamily: "appfont",
  );

  static TextStyle font24BlueBold = TextStyle(
    fontSize: 24.sp,
    color: const Color(0xff4CB5ED),
    fontWeight: FontWeightHelper.bold,
    fontFamily: "appfont",
  );

  static TextStyle font16textbutton = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.regular,
    color: Colors.white,
    fontFamily: "appfont",
  );

  static TextStyle font20Bold = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeightHelper.bold,
    color: const Color(0xff959595),
    fontFamily: "appfont",
  );

  static TextStyle font16form = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.regular,
    fontFamily: "appfont",
    color: ColorsManager.formgrey,
  );

  static TextStyle font15homefooter = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.regular,
    fontFamily: "appfont",
    color: Colors.white,
  );

  static TextStyle font15Regular = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.regular,
    fontFamily: "appfont",
  );

  static TextStyle textsection = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.regular,
    fontFamily: "appfont",
    color: Colors.white,
  );
}
