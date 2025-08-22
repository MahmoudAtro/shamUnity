import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/feature/profile_edit/widgets/password_change_section.dart';
import 'package:shamunity/feature/profile_edit/widgets/profile_info_section.dart';
import 'package:shamunity/logic/profile_edit/cubit/profile_edit_cubit.dart';
import 'package:shamunity/logic/profile_edit/cubit/profile_edit_state.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getit<ProfileEditCubit>(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'تعديل المعلومات الشخصية',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14.sp,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.lock_outline),
                text: 'تغيير كلمة السر',
              ),
              Tab(
                icon: Icon(Icons.person_outline),
                text: 'المعلومات الشخصية',
              ),
            ],
          ),
        ),
        body: BlocListener<ProfileEditCubit, ProfileEditState>(
          listener: (context, state) {
            if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is PasswordChangeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تحديث المعلومات بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProfileUpdateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              // قسم تغيير كلمة السر
              const PasswordChangeSection(),
              // قسم تعديل المعلومات الشخصية
              ProfileInfoSection(),
            ],
          ),
        ),
      ),
    );
  }
}
