import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImageViewerScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _buildImageViewer(context),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: _buildImageWidget(),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'رابط الصورة: $imageUrl',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showOpenOptions(context),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('خيارات الفتح'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _fullScreenView(),
                      icon: const Icon(Icons.fullscreen),
                      label: const Text('ملء الشاشة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // هنا يمكن إضافة مكتبة cached_network_image لتحميل الصور
    // حالياً سأعرض أيقونة مؤقتة

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'عرض الصورة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openInBrowser(BuildContext context) async {
    try {
      // فتح الصورة في المتصفح
      final url = Uri.parse(imageUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }

      // حالياً سأعرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('جاري فتح $title في المتصفح...'),
          backgroundColor: Colors.blue,
          action: SnackBarAction(
            label: 'إغلاق',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في فتح الصورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openWithGoogleDrive(BuildContext context) async {
    try {
      // فتح الصورة في Google Drive
      String driveUrl;

      if (Platform.isAndroid) {
        // للـ Android: استخدام intent
        driveUrl =
            'intent://drive.google.com/viewer?url=$imageUrl#Intent;package=com.google.android.apps.docs;end';
      } else if (Platform.isIOS) {
        // للـ iOS: استخدام deep link
        driveUrl = 'googledrive://$imageUrl';
      } else {
        // للويب: فتح في المتصفح
        driveUrl = 'https://drive.google.com/viewer?url=$imageUrl';
      }

      // فتح الرابط
      final url = Uri.parse(driveUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // إذا فشل فتح Google Drive، افتح في المتصفح
        final webUrl =
            Uri.parse('https://drive.google.com/viewer?url=$imageUrl');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('جاري فتح $title في Google Drive...'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'إغلاق',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في فتح الصورة في Google Drive: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOpenOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_browser, color: Colors.blue),
              title: const Text('فتح في المتصفح'),
              subtitle: const Text('عرض الصورة في متصفح الويب'),
              onTap: () {
                Navigator.pop(context);
                _openInBrowser(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline,
                  color: Colors.green),
              title: const Text('فتح مع Google Drive'),
              subtitle: const Text('عرض الصورة في تطبيق Google Drive'),
              onTap: () {
                Navigator.pop(context);
                _openWithGoogleDrive(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fullscreen, color: Colors.purple),
              title: const Text('عرض بملء الشاشة'),
              subtitle: const Text('عرض الصورة بملء الشاشة'),
              onTap: () {
                Navigator.pop(context);
                _fullScreenView();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _fullScreenView() {
    // TODO: إضافة منطق عرض الصورة بملء الشاشة
    // يمكن استخدام مكتبة مثل photo_view
  }
}
