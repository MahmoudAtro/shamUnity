import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/observer/app_observer.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/my_app.dart';
import 'package:shamunity/routes/routers_define.dart';
void main() async {
  ServicesLocator().init();
  await ScreenUtil.ensureScreenSize();
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  runApp(
    MyApp(
       appRoute: AppRoute(),
    ),
  );
}
