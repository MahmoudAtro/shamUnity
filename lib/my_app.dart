import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/routes/routers_define.dart';
import 'package:shamunity/routes/routes_name.dart';
import 'package:toastification/toastification.dart';

class MyApp extends StatelessWidget {
  final AppRoute appRoute;

  const MyApp({super.key, required this.appRoute});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: ScreenUtilInit(
          designSize: const Size(402, 874),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
            onGenerateRoute: appRoute.generateRoute,
            builder: (context, widget) {
              return Directionality(
                textDirection: TextDirection
                    .rtl, // الاتجاه الافتراضي: من اليمين إلى اليسار
                child: widget!,
              );
            },
            initialRoute: RoutesNames.homePage,
            // darkTheme: ThemeData.dark(),
            theme: ThemeData.light(),
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar', 'SA'),
            title: 'Sham Unity',
          )),
    );
  }
}
