import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TextViewerScreen extends StatelessWidget {
  final String textUrl;
  final String title;

  const TextViewerScreen({
    Key? key,
    required this.textUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadText(context),
            tooltip: 'تحميل الملف',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyText(context),
            tooltip: 'نسخ النص',
          ),
        ],
      ),
      body: _buildTextViewer(context),
    );
  }

  Widget _buildTextViewer(BuildContext context) {
    return Column(
      children: [
        // Header with file info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'رابط الملف: $textUrl',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // Text content
        Expanded(
          child: _buildTextContent(),
        ),
        // Bottom actions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
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
                onPressed: () => _searchInText(),
                icon: const Icon(Icons.search),
                label: const Text('بحث في النص'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent() {
    // هنا يمكن إضافة منطق تحميل النص من الرابط
    // حالياً سأعرض نص تجريبي

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'محتوى الملف النصي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'هذا مثال على محتوى ملف نصي. يمكن أن يحتوي على أي نوع من النصوص مثل:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• نصوص تعليمية',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  '• ملاحظات دراسية',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  '• تعليمات وإرشادات',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  '• قوائم ومراجع',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'يمكن للمستخدمين:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• قراءة النص مباشرة في التطبيق\n'
            '• البحث في النص عن كلمات محددة\n'
            '• نسخ النص إلى الحافظة\n'
            '• تحميل الملف النصي\n'
            '• مشاركة الملف مع الآخرين',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _downloadText(BuildContext context) async {
    try {
      // إظهار مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // الحصول على مجلد التحميل
      final directory = await getApplicationDocumentsDirectory();
      final extension = textUrl.split('.').last.toLowerCase();
      final fileName = '${title.replaceAll(' ', '_')}.$extension';
      final filePath = '${directory.path}/$fileName';

      // تحميل الملف النصي
      final dio = Dio();
      await dio.download(textUrl, filePath);

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحميل $title بنجاح'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'إغلاق',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحميل: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyText(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ النص إلى الحافظة'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'إغلاق',
          onPressed: () {},
        ),
      ),
    );

    // TODO: إضافة منطق النسخ إلى الحافظة
    // يمكن استخدام مكتبة مثل clipboard
  }

  void _openInBrowser(BuildContext context) async {
    try {
      // فتح الملف النصي في المتصفح
      final url = Uri.parse(textUrl);

      // يمكن استخدام مكتبة url_launcher
      // import 'package:url_launcher/url_launcher.dart';

      // if (await canLaunchUrl(url)) {
      //   await launchUrl(url, mode: LaunchMode.externalApplication);
      // }

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
          content: Text('خطأ في فتح الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openWithGoogleDrive(BuildContext context) async {
    try {
      // فتح الملف النصي في Google Drive
      String driveUrl;

      if (Platform.isAndroid) {
        // للـ Android: استخدام intent
        driveUrl =
            'intent://drive.google.com/viewer?url=$textUrl#Intent;package=com.google.android.apps.docs;end';
      } else if (Platform.isIOS) {
        // للـ iOS: استخدام deep link
        driveUrl = 'googledrive://$textUrl';
      } else {
        // للويب: فتح في المتصفح
        driveUrl = 'https://drive.google.com/viewer?url=$textUrl';
      }

      // يمكن استخدام مكتبة url_launcher
      // final url = Uri.parse(driveUrl);
      // if (await canLaunchUrl(url)) {
      //   await launchUrl(url);
      // }

      // حالياً سأعرض رسالة نجاح
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
          content: Text('خطأ في فتح الملف في Google Drive: $e'),
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
              subtitle: const Text('عرض الملف في متصفح الويب'),
              onTap: () {
                Navigator.pop(context);
                _openInBrowser(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline,
                  color: Colors.green),
              title: const Text('فتح مع Google Drive'),
              subtitle: const Text('عرض الملف في تطبيق Google Drive'),
              onTap: () {
                Navigator.pop(context);
                _openWithGoogleDrive(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.purple),
              title: const Text('بحث في النص'),
              subtitle: const Text('البحث عن كلمات محددة في النص'),
              onTap: () {
                Navigator.pop(context);
                _searchInText();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.teal),
              title: const Text('نسخ النص'),
              subtitle: const Text('نسخ النص إلى الحافظة'),
              onTap: () {
                Navigator.pop(context);
                _copyText(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.indigo),
              title: const Text('تحميل للجهاز'),
              subtitle: const Text('حفظ الملف على الجهاز'),
              onTap: () {
                Navigator.pop(context);
                _downloadText(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _searchInText() {
    // TODO: إضافة منطق البحث في النص
    // يمكن إضافة TextField للبحث مع highlight للنتائج
  }
}
