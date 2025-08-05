import 'package:flutter/material.dart';
import 'package:shamunity/feature/auth/enter_platform_screen.dart';
import 'package:shamunity/feature/auth/login/login_screen.dart';
import 'package:shamunity/feature/auth/signup/signup_screen.dart';
import 'package:shamunity/feature/auth/signup/agreement_screen.dart';
import 'package:shamunity/feature/auth/signup/university_info_screen.dart';
import 'package:shamunity/feature/homepage.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class AppRoute {
  Route generateRoute(RouteSettings route) {
    // this argument to be passed in any screen like this
    // final argument = route.arguments;
    switch (route.name) {
      case RoutesNames.homePage:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case RoutesNames.enterPlatform:
        return MaterialPageRoute(
          builder: (_) => const EnterPlatformScreen(),
        );
      case RoutesNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case RoutesNames.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );
      case RoutesNames.universityInfo:
        return MaterialPageRoute(
          builder: (_) => const UniversityInfoScreen(),
        );
      case RoutesNames.agreement:
        return MaterialPageRoute(
          builder: (_) => const AgreementScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    (_).pop();
                  },
                  icon: const Icon(Icons.arrow_back)),
            ),
            body: Center(
              child: Text("No route define for ${route.name}"),
            ),
          ),
        );
    }
  }
}
