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
                  builder: (BuildContext context) =>
                      const LoadingDialogWidget());
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
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text(
                "إنشاء منشور",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                TextButton(
                  onPressed: _submitPost,
                  child: const Text(
                    "نشر",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====== شريط الملف الشخصي ======
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: user!.profilePictureUrl != null
                              ? NetworkImage(
                                  "${ApiConstances.baseUrlImg}${user!.profilePictureUrl!}")
                              : const AssetImage(
                                      'assets/images/default_avatar.jpg')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.user.firstName} ${widget.user.lastName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${user?.role} 🎓" ,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.blueAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // ====== مربع الكتابة ======
                    TextField(
                      controller: _controller,
                      maxLines: null,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                      decoration: const InputDecoration(
                        hintText:
                            "بم تفكر اليوم؟ شارك فكرة، ملخص، أو نصيحة لزملائك...",
                        border: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ====== معاينة الصورة ======
                    if (_selectedImage != null) ...[
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                              onPressed: () =>
                                  setState(() => _selectedImage = null),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],

                    // ====== أدوات الإضافة (صورة - ملف - وسم جامعي) ======
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPostTool(
                              icon: Icons.image,
                              color: Colors.green,
                              label: "صورة",
                              onTap: _pickImage,
                            ),
                            _buildPostTool(
                              icon: Icons.insert_drive_file,
                              color: Colors.orange,
                              label: "ملف",
                              onTap: () {
                                debugPrint("📂 اختيار ملف");
                              },
                            ),
                            _buildPostTool(
                              icon: Icons.school,
                              color: Colors.blue,
                              label: "إنجاز جامعي",
                              onTap: () {
                                debugPrint("🎓 اختيار مادة/محاضرة");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // ====== Widget مساعد للأدوات ======
  Widget _buildPostTool({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
