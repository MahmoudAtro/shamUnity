import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shamunity/feature/post/widget/post_widget.dart';
import 'package:shamunity/models/post.dart';
import 'package:shamunity/models/user_model.dart';

class ProfileWidget extends StatefulWidget {
  final UserModel user;
  final List<PostModel> posts;

  const ProfileWidget({
    super.key,
    required this.user,
    required this.posts,
  });

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("التقاط صورة"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("اختيار من المعرض"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      children: [
        // صورة الملف الشخصي
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 104,
                      backgroundColor: Colors.blueAccent,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : NetworkImage(widget.user.avatarUrl)
                                as ImageProvider,
                      ),
                    ),
                    InkWell(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(widget.user.name, style: const TextStyle(fontSize: 30)),
            ],
          ),
        ),

        // معلومات المستخدم
        Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.school, size: 22, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text("السنة الدراسية: ${widget.user.academicYear}",
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.badge, size: 22, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text("الرقم الجامعي: ${widget.user.id}",
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_city,
                        size: 22, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text("الجامعة: ${widget.user.university}",
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Text("المنشورات",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...widget.posts.map((post) => PostWidget(post: post)).toList(),
      ],
    );
  }
}
