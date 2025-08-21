import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFViewerScreen extends StatelessWidget {
  final String fileUrl;
  final String title;

  const PDFViewerScreen({
    Key? key,
    required this.fileUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: _buildPDFViewer(context),
    );
  }

  Widget _buildPDFViewer(BuildContext context) {
    // هنا يمكن إضافة مكتبة flutter_pdfview لعرض PDF
    // حالياً سأعرض رسالة مؤقتة

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 100,
            color: Colors.red[400],
          ),
          const SizedBox(height: 24),
          Text(
            'عرض ملف PDF',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'رابط الملف: $fileUrl',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showOpenOptions(context),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('خيارات الفتح'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _openInBrowser(BuildContext context) async {
    try {
      // فتح الملف في المتصفح
      final url = Uri.parse(fileUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }

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
      // رابط Google Drive Viewer
      final driveUrl =
          'https://drive.google.com/viewerng/viewer?embedded=true&url=$fileUrl';
      final uri = Uri.parse(driveUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

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
      } else {
        throw 'تعذر فتح Google Drive';
      }
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
          ],
        ),
      ),
    );
  }
}
