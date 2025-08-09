import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/feature/auth/enter_platform_screen.dart';
import 'package:shamunity/feature/auth/login/login_screen.dart';
import 'package:shamunity/feature/auth/signup/agreement_screen.dart';
import 'package:shamunity/feature/auth/signup/signup_screen.dart';
import 'package:shamunity/feature/auth/signup/university_info_screen.dart';
import 'package:shamunity/feature/auth/verification-otp/verification_code_screen.dart';
import 'package:shamunity/feature/post/edite%20post/edit_post_srcreen.dart';
import 'package:shamunity/feature/home/view/ui/create_post_view.dart';
import 'package:shamunity/feature/home/view/ui/home.dart';
import 'package:shamunity/feature/library/academic_years_grid_view.dart';
import 'package:shamunity/feature/library/department_view.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/library/subjects_grid_screen.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';
import 'package:shamunity/feature/profile/profile_view.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';
import 'package:shamunity/models/college_model.dart';
import 'package:shamunity/models/post.dart';
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
          builder: (_) => BlocProvider(
            create: (context) => getit<PostCubit>(),
            child: const HomePage(),
          ),
        );
      case RoutesNames.createPost:
        return MaterialPageRoute(
          builder: (_) => CreatePostScreen(user: route.arguments as UserModel),
        );
      case RoutesNames.libraryHome:
        return MaterialPageRoute(
          builder: (_) => const LibraryHomeScreen(),
        );
      case RoutesNames.profile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getit<PostCubit>(),
            child: const ProfileScreen(),
          ),
        );
      case RoutesNames.libraryBooksTab:
        return MaterialPageRoute(
          builder: (_) => const LibraryBooksTab(),
        );
      case RoutesNames.editPost:
        return MaterialPageRoute(
          builder: (_) => EditPostScreen(post: route.arguments as Post),
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
          builder: (_) => BlocProvider(
            create: (BuildContext context) => getit<RegisterBloc>(),
            child: const SignupScreen(),
          ),
        );
      case RoutesNames.universityInfo:
        final registerBloc = getit<RegisterBloc>();
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: registerBloc,
            child: const UniversityInfoScreen(),
          ),
        );
      case RoutesNames.agreement:
        final registerBloc = getit<RegisterBloc>();
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: registerBloc,
            child: const AgreementScreen(),
          ),
        );
      case RoutesNames.verification:
        return MaterialPageRoute(
          builder: (_) => VerificationCodeScreen(
            email: route.arguments as String,
          ),
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
