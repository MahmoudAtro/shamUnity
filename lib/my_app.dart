import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/routes/routers_define.dart';
import 'package:shamunity/routes/routes_name.dart';
import 'package:toastification/toastification.dart';
import 'package:app_links/app_links.dart';

class MyApp extends StatefulWidget {
  final AppRoute appRoute;

  const MyApp({super.key, required this.appRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: ScreenUtilInit(
          designSize: const Size(402, 874),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
            onGenerateRoute: widget.appRoute.generateRoute,
            builder: (context, widget) {
              return Directionality(
                textDirection: TextDirection
                    .rtl, // الاتجاه الافتراضي: من اليمين إلى اليسار
                child: widget!,
              );
            },
            navigatorKey: SingleInstanceService.navigatorKey,
            initialRoute: isLoggedInUser
                ? RoutesNames.homePage
                : RoutesNames.enterPlatform,
            darkTheme: ThemeData.dark(),
            theme: ThemeData.light(),
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar', 'SA'),
            title: 'Sham Unity',
          )),
    );
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // 1. تحقق من الرابط الذي قام بفتح التطبيق (إذا كان مغلقًا)
    // final initialUri = await _appLinks.getInitialLink();
    // if (initialUri != null) {
    //   print('Initial link received: $initialUri');
    //   _processLink(initialUri);
    // }

    // 2. استمع للروابط القادمة بينما التطبيق مفتوح
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('Latest link received: $uri');
      _processLink(uri);
    });
  }

  /// هذه الدالة تبقى كما هي، وظيفتها معالجة الرابط
  void _processLink(Uri uri) {
    // تحقق مما إذا كان الرابط هو رابط إعادة تعيين كلمة المرور
    if (uri.host == 'reset-password') {
      // استخرج التوكن والإيميل من الرابط
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];

      if (token != null && email != null) {
        print('Password Reset Token: $token');
        print('Email: $email');

        // الآن، قم بتوجيه المستخدم إلى شاشة إعادة تعيين كلمة المرور
        // وقم بتمرير التوكن والإيميل إليها
        SingleInstanceService.navigatorKey.currentState?.pushNamed(
          '/reset-password',
          arguments: {'token': token, 'email': email},
        );
      }
    }
  }
}
