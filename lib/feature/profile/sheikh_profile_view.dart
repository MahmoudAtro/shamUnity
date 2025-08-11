import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/feature/profile/widget/sheikh_profile_widget.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_cubit.dart';

class SheikhProfileScreen extends StatefulWidget {
  final int userId;

  const SheikhProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SheikhProfileScreen> createState() => _SheikhProfileScreenState();
}

class _SheikhProfileScreenState extends State<SheikhProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: getit<VisitedUserProfileCubit>(),
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          body: SheikhProfileWidget(userId: widget.userId),
        ));
  }
}
