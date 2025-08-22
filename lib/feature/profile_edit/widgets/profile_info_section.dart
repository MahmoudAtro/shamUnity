import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/logic/profile_edit/cubit/profile_edit_cubit.dart';
import 'package:shamunity/logic/profile_edit/cubit/profile_edit_state.dart';

class ProfileInfoSection extends StatefulWidget {
  const ProfileInfoSection({
    super.key,
  });

  @override
  State<ProfileInfoSection> createState() => _ProfileInfoSectionState();
}

class _ProfileInfoSectionState extends State<ProfileInfoSection> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    if (user != null) {
      _firstNameController.text = user!.firstName;
      _lastNameController.text = user!.lastName;
      _currentImageUrl = user!.profilePictureUrl;
    }
  }

  @override
  void didUpdateWidget(ProfileInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث الحقول عند تغيير البيانات العامة
    _initializeUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة الصورة الشخصية
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text(
                      'الصورة الشخصية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _buildProfileImage(),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('تغيير الصورة'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // بطاقة المعلومات الشخصية
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المعلومات الشخصية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الأول',
                        hintText: 'أدخل الاسم الأول',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال الاسم الأول';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الأخير',
                        hintText: 'أدخل الاسم الأخير',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال الاسم الأخير';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // أزرار التحديث
            BlocBuilder<ProfileEditCubit, ProfileEditState>(
              builder: (context, state) {
                final isLoading = state is ProfileUpdateLoading;

                return Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _updateNameAndPicture,
                      icon: isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.update),
                      label: Text(
                        'تحديث المعلومات',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: 16.h, horizontal: 10.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return Image.network(
        "${ApiConstances.baseUrlImg}$_currentImageUrl",
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 60.sp,
        color: Colors.grey[400],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار الصورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateNameAndPicture() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileEditCubit>().updateUserProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            profilePicturePath: _selectedImage?.path,
          );
    }
  }
}
