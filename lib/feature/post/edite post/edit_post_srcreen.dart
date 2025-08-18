import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_cubit.dart';
import 'package:shamunity/logic/post%20bloc/cubit/post_cubit_state.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/routes/extension.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _controller;
  late PostCubit _postCubit;
  File? _selectedImage;
  bool imageChanged = false;

  @override
  void initState() {
    super.initState();
    _postCubit = PostCubit(getit());
    _controller = TextEditingController(text: widget.post.content);
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
                  setState(() {
                    _selectedImage = File(picked.path);
                    imageChanged = true;
                  });
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
                  setState(() {
                    _selectedImage = File(picked.path);
                    imageChanged = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitEdit() {
    final text = _controller.text.trim();
    if (text.isEmpty &&
        _selectedImage == null &&
        widget.post.imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة شيء أو اختيار صورة')),
      );
      return;
    }

    // إرسال التعديل للبلوك
    final updatedPost = widget.post.copyWith(
      content: text,
      imageUrl:
          _selectedImage != null ? _selectedImage!.path : widget.post.imageUrl,
    );
    _postCubit.updatePost(widget.post.id, updatedPost);
  }

  @override
  void dispose() {
    _controller.dispose();
    _selectedImage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageChanged ? _selectedImage != null : widget.post.imageUrl != null;

    return BlocProvider(
      create: (context) => _postCubit,
      child: BlocListener<PostCubit, PostCubitState>(
        listener: (context, state) {
          if (state is PostUpdatedLoading) {
            showDialog(
              context: context,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
            // يغلق الـ Dialog
          } else if (state is PostUpdatedError) {
            context.pop();
            Toast().error(context, state.message);
          } else if (state is PostUpdatedSuccess) {
            context.pop();
            Toast().success(context, "تم تعديل المنشور بنجاح");
            context.pop();
            context.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("تعديل المنشور"),
            actions: [
              TextButton(
                onPressed: _submitEdit,
                child: const Text("حفظ",
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
                        backgroundImage: widget.post.author.profilePicture !=
                                null
                            ? NetworkImage(
                                "${ApiConstances.baseUrlImg}${widget.post.author.profilePicture}")
                            : null,
                        radius: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.post.author.name,
                        style: TextStyle(
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

                  // معاينة الصورة إذا وجدت
                  if (hasImage) ...[
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageChanged && _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  height: 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  "${ApiConstances.baseUrlImg}${widget.post.imageUrl!}",
                                  height: 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
                  ],

                  // زر إضافة صورة إذا لم توجد صورة
                  if (!hasImage)
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
