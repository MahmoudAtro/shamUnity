import 'package:flutter/material.dart';
import 'package:shamunity/feature/home/view/ui/create_post_view.dart';
import 'package:shamunity/feature/home/view/ui/home.dart';
import 'package:shamunity/feature/library/academic_years_grid_view.dart';
import 'package:shamunity/feature/library/department_view.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/library/subjects_grid_screen.dart';
import 'package:shamunity/feature/profile/profile_view.dart';
import 'package:shamunity/models/college_model.dart';
import 'package:shamunity/models/user_model.dart';
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
          builder: (_) => HomePage(),
        );
      case RoutesNames.createPost:
        return MaterialPageRoute(
          builder: (_) => CreatePostScreen(user: route.arguments as UserModel),
        );
      case RoutesNames.libraryHome:
        return MaterialPageRoute(
          builder: (_) => LibraryHomeScreen(),
        );
      case RoutesNames.profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(),
        );
      case RoutesNames.libraryBooksTab:
        return MaterialPageRoute(
          builder: (_) => LibraryBooksTab(),
        );
      case RoutesNames.academicYearsGrid:
        return MaterialPageRoute(
          builder: (_) => AcademicYearsGridScreen(
            years: route.arguments as List<AcademicYearModel>,
          ),
        );
      case RoutesNames.departmentDetails:
        return MaterialPageRoute(
          builder: (_) => DepartmentsGridScreen(
            departments: route.arguments as List<DepartmentModel>,
          ),
        );

      case RoutesNames.subjectsGrid:
        return MaterialPageRoute(
          builder: (_) => SubjectsGridScreen(
            subjectModel: route.arguments as List<SubjectModel>,
          ),
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
