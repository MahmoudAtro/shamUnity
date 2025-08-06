import 'package:flutter/material.dart';
import 'package:shamunity/feature/home/view/ui/create_post_view.dart';
import 'package:shamunity/feature/home/view/ui/home.dart';
import 'package:shamunity/feature/library/academic_years_grid_view.dart';
import 'package:shamunity/feature/library/department_view.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/library/subjects_grid_screen.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';
import 'package:shamunity/feature/profile/profile_view.dart';
import 'package:shamunity/models/college_model.dart';
import 'package:shamunity/models/user_model.dart';
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
      case RoutesNames.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
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
