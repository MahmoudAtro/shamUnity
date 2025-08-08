import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/feature/profile/widget/profile_widget.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<PostCubit, PostCubitState>(
        builder: (context, state) {
          if (state is PostCubitLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostCubitLoaded) {
            return ProfileWidget();
          } else {
            return const Center(child: Text("Error loading profile"));
          }
        },
      ),
    );
  }
}
