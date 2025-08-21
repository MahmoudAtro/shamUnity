import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/loading_dialog_widget.dart';
import 'package:shamunity/feature/post/post_list_view.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_state.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/extension.dart';

class CreatePostScreen extends StatefulWidget {
  final UserModel user;
  const CreatePostScreen({super.key, required this.user});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedImage;
  late PostCubit _postCubit;

  @override
  void initState() {
    super.initState();
    _postCubit = PostCubit(getit());
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final picked =
                    await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _selectedImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final picked =
                    await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => _selectedImage = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitPost() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة شيء أو اختيار صورة')),
      );
      return;
    }
    _postCubit.createPost(
      content: text,
      image: _selectedImage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _selectedImage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _postCubit,
      child: BlocListener<PostCubit, PostCubitState>(
        listener: (context, state) {
          if (state is PostCreatedLoading) {
            showDialog(
                context: context,
                builder: (BuildContext context) => const LoadingDialogWidget());
          } else if (state is PostCreatedSuccess) {
            context.pop();
            Toast().success(context, "تم نشر المنشور بنجاح");
            context.pop();
          } else if (state is PostCreatedError) {
            context.pop();
            Toast().error(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("إنشاء منشور"),
            actions: [
              TextButton(
                onPressed: _submitPost,
                child: const Text("نشر",
                    style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // شريط الملف الشخصي
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user!.profilePictureUrl != null
                            ? NetworkImage(
                                "${ApiConstances.baseUrlImg}${user!.profilePictureUrl!}")
                            : const AssetImage(
                                'assets/images/default_avatar.jpg'),
                        radius: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${widget.user.firstName} ${widget.user.lastName}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // مربع الكتابة
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "بم تفكر؟",
                      border: InputBorder.none,
                    ),
                  ),

                  // معاينة الصورة
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 350,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 50),
                  // InkWell(
                  //   onTap: _pickImage,
                  //   child: Row(
                  //     children: [
                  //       IconButton(
                  //         icon: const Icon(Icons.image, color: Colors.green),
                  //         onPressed: _pickImage,
                  //       ),
                  //       const Text("إضافة صورة", style: TextStyle(fontSize: 14)),
                  //     ],
                  //   ),
                  // ),
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 75, color: Colors.green),
                          SizedBox(height: 8),
                          Text("إضافة صورة", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
