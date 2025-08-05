import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/constants/colors.dart';
import 'package:shamunity/core/helpers/space_helper.dart';
import 'package:shamunity/routes/extension.dart';

class EnterPlatformScreen extends StatelessWidget {
  const EnterPlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
        ),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/images/bacground_chat.png"),
          fit: BoxFit.cover,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            verticalspace(20),
            Image.asset(
              "assets/images/logo.png",
              width: 180.w,
              height: 75.h,
              fit: BoxFit.cover,
            ),
            Text(
              "كيف تريد الدخول الى المنصة ؟",
              style: TextStyle(
                  fontSize: 23.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.mainBlue),
            ),
            verticalspace(60),
            Container(
              width: double.infinity,
              height: 230.h,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ColorsManager.gold,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 180.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'مشاهد',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  verticalspace(20),
                  const Text(
                    "عند دخولك، يمكنك مشاهدة ما يحدث على المنصة \n فقط للمعرفة والمشاهدة دون تفاعل.",
                    style: TextStyle(color: ColorsManager.lightBlue),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            verticalspace(60),
            Container(
              width: double.infinity,
              height: 230.h,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ColorsManager.mainBlue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pushNamed('/login');
                    },
                    child: Container(
                      width: 180.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'مستخدم',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  verticalspace(20),
                  const Text(
                    "عند تسجيل الدخول كمستخدم لهذه المنصة \n يمكنك الاستمتاع بجميع الميزات التي تقدمها",
                    style: TextStyle(color: ColorsManager.lightBlue),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
