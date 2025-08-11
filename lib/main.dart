import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/helpers/shared_helpers.dart';
import 'package:shamunity/core/observer/app_observer.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/my_app.dart';
import 'package:shamunity/routes/routers_define.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String GOOGLE_API_KEY = "AIzaSyC6axuoPVYSz44nqdlYJbE_zh_7ZU1RQec";
  // const String GOOGLE_API_KEY = "AIzaSyBcQETqzk-xCkdaaJmp8NP1RKktDWAxmGw";
  Gemini.init(
    apiKey: GOOGLE_API_KEY,
  );
  ServicesLocator().init();
  await checkIfUserLogged();
  await ScreenUtil.ensureScreenSize();
  Bloc.observer = AppBlocObserver();
  runApp(
    MyApp(
      appRoute: AppRoute(),
    ),
  );
}

checkIfUserLogged() async {
  String? userToken = await SecureSharedPrefHelper.getString("userToken");
  if (userToken!.isNotEmpty || userToken != "") {
    isLoggedInUser = true;
  } else {
    isLoggedInUser = false;
  }
}
