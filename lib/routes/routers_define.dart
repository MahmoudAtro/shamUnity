import 'package:flutter/material.dart';
import 'package:shamunity/feature/home/home/view/ui/create_post_view.dart';
import 'package:shamunity/feature/home/home/view/ui/home.dart';
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
          builder: (_) =>  HomePage(),
        );
      case RoutesNames.createPost:
        return MaterialPageRoute(
          builder: (_) =>  CreatePostScreen(user: route.arguments as UserModel),
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
