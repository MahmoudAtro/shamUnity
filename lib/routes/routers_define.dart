import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/feature/auth/enter_platform_screen.dart';
import 'package:shamunity/feature/auth/forget-password/check_otp_password.dart';
import 'package:shamunity/feature/auth/forget-password/forget_password.dart';
import 'package:shamunity/feature/auth/forget-password/rest_password.dart';
import 'package:shamunity/feature/auth/login/login_screen.dart';
import 'package:shamunity/feature/auth/signup/agreement_screen.dart';
import 'package:shamunity/feature/auth/signup/signup_screen.dart';
import 'package:shamunity/feature/auth/signup/university_info_screen.dart';
import 'package:shamunity/feature/auth/verification-otp/verification_code_screen.dart';
import 'package:shamunity/feature/chat/user/user_chat_screen.dart';
import 'package:shamunity/feature/shamunityAi/chat_app.dart';
import 'package:shamunity/feature/home/view/ui/home.dart';
import 'package:shamunity/feature/library/academic_years_grid_view.dart';
import 'package:shamunity/feature/library/department_view.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/feature/library/subjects_grid_screen.dart';
import 'package:shamunity/feature/notification/notification_srcreen.dart';
import 'package:shamunity/feature/post/create_post_view.dart';
import 'package:shamunity/feature/post/edite%20post/edit_post_srcreen.dart';
import 'package:shamunity/feature/profile/profile_view.dart';
import 'package:shamunity/feature/profile/sheikh_profile_view.dart';
import 'package:shamunity/feature/search/search_screen.dart';
import 'package:shamunity/feature/suggesation/suggesation_seceen.dart';
import 'package:shamunity/logic/cubit/comment_cubit.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';
import 'package:shamunity/logic/search%20bloc/search_cubit.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_cubit.dart';
import 'package:shamunity/models/college_model.dart';
import 'package:shamunity/models/conversation_model.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class AppRoute {
  Route generateRoute(RouteSettings route) {
    // this argument to be passed in any screen like this
    // final argument = route.arguments;
    switch (route.name) {
      case RoutesNames.homePage:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => getit<VisitedUserProfileCubit>()),
              BlocProvider(create: (context) => getit<CommentCubit>()),
            ],
            child: HomePage(currentIndex: route.arguments as int?),
          ),
        );
      case RoutesNames.suggesation:
        return MaterialPageRoute(
          builder: (_) => const FeedbackScreen(),
        );
      case RoutesNames.createPost:
        return MaterialPageRoute(
          builder: (_) => CreatePostScreen(user: route.arguments as UserModel),
        );
      case RoutesNames.userChatScreen:
        return MaterialPageRoute(
            builder: (_) => UserChatScreen(
                  conversation: route.arguments as ConversationResponseModel,
                ));
      case RoutesNames.libraryHome:
        return MaterialPageRoute(
          builder: (_) => const LibraryHomeScreen(),
        );
      case RoutesNames.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      case RoutesNames.libraryBooksTab:
        return MaterialPageRoute(
          builder: (_) => const LibraryBooksTab(),
        );
      case RoutesNames.editPost:
        return MaterialPageRoute(
          builder: (_) => EditPostScreen(post: route.arguments as Post),
        );
      case RoutesNames.search:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getit<SearchCubit>()),
            ],
            child: const SearchScreen(),
          ),
        );
      case RoutesNames.restPassword:
        return MaterialPageRoute(builder: (_) {
          final args = route.arguments as Map<String, dynamic>? ?? {};
          return RestPassword(
            email: args['email'] as String? ?? '',
            token: args['token'] as String? ?? '',
          );
        });
      case RoutesNames.checkOtp:
        return MaterialPageRoute(builder: (_) {
          return CheckOtpPassword(
            email: route.arguments as String? ?? '',
          );
        });

      case RoutesNames.sheikhProfile:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => getit<VisitedUserProfileCubit>()),
              BlocProvider(create: (context) => getit<CommentCubit>()),
            ],
            child: SheikhProfileScreen(userId: route.arguments as int),
          ),
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
      case RoutesNames.forgetPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgetPassword(),
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
      case RoutesNames.geminiChat:
        return MaterialPageRoute(
          builder: (_) => const ChatApp(),
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
