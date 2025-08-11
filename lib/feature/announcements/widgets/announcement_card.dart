import 'package:flutter/material.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/models/announcement.dart';
import 'package:url_launcher/url_launcher.dart';

import 'video_player_screen.dart';

/// بطاقة الإعلان التي تعرض المحتوى والملفات المرفقة
/// تدعم أنواع مختلفة من الملفات:
/// - الصور: jpg, jpeg, png, gif, webp, bmp, tiff
/// - الفيديوهات: mp4, avi, mov, wmv, flv, mkv, webm, 3gp, m4v
/// - المستندات: pdf, doc, docx, xls, xlsx, ppt, pptx, txt, rtf
/// - الأرشيف: zip, rar, 7z
/// - ملفات أخرى: يتم فتحها في التطبيق الخارجي

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  const AnnouncementCard({super.key, required this.announcement});

  // دالة مساعدة للتحقق من نوع الملف
  bool _isVideoFile(String fileType) {
    final cleanType = fileType.toLowerCase().replaceAll('.', '');
    return [
      'video',
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      'mkv',
      'webm',
      '3gp',
      'm4v'
    ].contains(cleanType);
  }

  // دالة مساعدة للتحقق من نوع الصورة
  bool _isImageFile(String fileType) {
    final cleanType = fileType.toLowerCase().replaceAll('.', '');
    return ['image', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff']
        .contains(cleanType);
  }

  // دالة لفتح الصورة في وضع ملء الشاشة
  void _openImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'عرض الصورة',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                '${ApiConstances.baseUrlImg}$imageUrl',
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // دالة لفتح الفيديو داخل التطبيق
  void _openVideo(BuildContext context, String videoUrl) {
    try {
      final fullVideoUrl = '${ApiConstances.baseUrlImg}$videoUrl';

      // التحقق من صحة الرابط
      if (fullVideoUrl.isEmpty || !fullVideoUrl.startsWith('http')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رابط الفيديو غير صحيح'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoUrl: fullVideoUrl,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في فتح الفيديو: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة لفتح ملف PDF
  void _openPDF(String pdfUrl) async {
    final url = '${ApiConstances.baseUrlImg}/$pdfUrl';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // إذا لم يتمكن من فتح PDF، حاول فتحه في متصفح
      final browserUrl =
          'https://mozilla.github.io/pdf.js/web/viewer.html?file=$url';
      final browserUri = Uri.parse(browserUrl);
      if (await canLaunchUrl(browserUri)) {
        await launchUrl(browserUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  // دالة لفتح أي ملف حسب نوعه
  void _openFile(BuildContext context, String fileUrl, String fileType) async {
    final url = '${ApiConstances.baseUrlImg}/$fileUrl';
    final uri = Uri.parse(url);

    try {
      // التحقق من صحة الرابط
      if (url.isEmpty || !url.startsWith('http')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رابط الملف غير صحيح'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // إذا كان الملف فيديو، افتحه داخل التطبيق
      if (_isVideoFile(fileType)) {
        _openVideo(context, fileUrl);
        return;
      }

      // إذا كان الملف صورة، افتحها في وضع ملء الشاشة
      if (_isImageFile(fileType)) {
        _openImageFullScreen(context, fileUrl);
        return;
      }

      // للملفات الأخرى، حاول فتحها في التطبيق الخارجي
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // إذا لم يتمكن من فتح الملف، اعرض رسالة للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن فتح ملف $fileType'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              onPressed: () => _openFile(context, fileUrl, fileType),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في فتح الملف: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            onPressed: () => _openFile(context, fileUrl, fileType),
          ),
        ),
      );
    }
  }

  // دالة لبناء معاينة الملف حسب نوعه
  Widget _buildFilePreview(
      BuildContext context, String fileType, String fileUrl) {
    // تنظيف نوع الملف وإزالة النقاط
    String cleanFileType = fileType.toLowerCase().replaceAll('.', '');

    switch (cleanFileType) {
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
      case 'tiff':
        return _buildImagePreview(context, fileUrl);

      case 'video':
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
      case '3gp':
      case 'm4v':
        return _buildVideoPreview(context, fileUrl);

      case 'pdf':
        return _buildPDFPreview(context, fileUrl);

      case 'doc':
      case 'docx':
        return _buildDocumentPreview(context, fileUrl, 'Word');

      case 'xls':
      case 'xlsx':
        return _buildDocumentPreview(context, fileUrl, 'Excel');

      case 'ppt':
      case 'pptx':
        return _buildDocumentPreview(context, fileUrl, 'PowerPoint');

      case 'txt':
      case 'rtf':
        return _buildDocumentPreview(context, fileUrl, 'Text');

      case 'zip':
      case 'rar':
      case '7z':
        return _buildArchivePreview(context, fileUrl, cleanFileType);

      default:
        return _buildGenericFilePreview(context, fileUrl, fileType);
    }
  }

  // معاينة الصور
  Widget _buildImagePreview(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () => _openImageFullScreen(context, imageUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                '${ApiConstances.baseUrlImg}/$imageUrl',
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue[500],
                        strokeWidth: 3,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
            // أيقونة التكبير في الزاوية
            // Positioned(
            //   top: 12,
            //   right: 12,
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.6),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: const Icon(
            //       Icons.zoom_in,
            //       color: Colors.white,
            //       size: 20,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // معاينة الفيديو
  Widget _buildVideoPreview(BuildContext context, String videoUrl) {
    return GestureDetector(
      onTap: () => _openVideo(context, videoUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[800]!,
                    Colors.grey[900]!,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
            // أيقونة التشغيل في الوسط
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            // نص "انقر للمشاهدة" في الأسفل
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'انقر للمشاهدة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // معاينة ملف PDF
  Widget _buildPDFPreview(BuildContext context, String pdfUrl) {
    return GestureDetector(
      onTap: () => _openPDF(pdfUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
            // أيقونة PDF في الزاوية
            // Positioned(
            //   top: 12,
            //   right: 12,
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.6),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: const Icon(
            //       Icons.picture_as_pdf,
            //       color: Colors.white,
            //       size: 20,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // معاينة المستندات
  Widget _buildDocumentPreview(
      BuildContext context, String fileUrl, String docType) {
    IconData iconData;
    Color backgroundColor;

    switch (docType) {
      case 'Word':
        iconData = Icons.description;
        backgroundColor = Colors.blue[600]!;
        break;
      case 'Excel':
        iconData = Icons.table_chart;
        backgroundColor = Colors.green[600]!;
        break;
      case 'PowerPoint':
        iconData = Icons.slideshow;
        backgroundColor = Colors.orange[600]!;
        break;
      case 'Text':
        iconData = Icons.text_snippet;
        backgroundColor = Colors.grey[600]!;
        break;
      default:
        iconData = Icons.insert_drive_file;
        backgroundColor = Colors.grey[600]!;
    }

    return GestureDetector(
      onTap: () => _openFile(context, fileUrl, docType),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
            // أيقونة المستند في الزاوية
            // Positioned(
            //   top: 12,
            //   right: 12,
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.6),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: Icon(
            //       iconData,
            //       color: Colors.white,
            //       size: 20,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // معاينة ملفات الأرشيف
  Widget _buildArchivePreview(
      BuildContext context, String fileUrl, String archiveType) {
    IconData iconData;
    Color backgroundColor;

    switch (archiveType) {
      case 'zip':
        iconData = Icons.archive;
        backgroundColor = Colors.orange[600]!;
        break;
      case 'rar':
        iconData = Icons.archive;
        backgroundColor = Colors.red[600]!;
        break;
      case '7z':
        iconData = Icons.archive;
        backgroundColor = Colors.purple[600]!;
        break;
      default:
        iconData = Icons.archive;
        backgroundColor = Colors.grey[600]!;
    }

    return GestureDetector(
      onTap: () => _openFile(context, fileUrl, 'أرشيف'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // معاينة الملفات العامة
  Widget _buildGenericFilePreview(
      BuildContext context, String fileUrl, String fileType) {
    return GestureDetector(
      onTap: () => _openFile(context, fileUrl, fileType),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.insert_drive_file,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
            // أيقونة الملف في الزاوية
            // Positioned(
            //   top: 12,
            //   right: 12,
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.6),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: const Icon(
            //       Icons.insert_drive_file,
            //       color: Colors.white,
            //       size: 20,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الملف في الأعلى - يدعم جميع أنواع الملفات
          if (announcement.fileUrl != null)
            _buildFilePreview(
                context, announcement.fileType!, announcement.fileUrl!),

          // النص تحت الملف
          if (announcement.content != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                announcement.content!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

          // التاريخ في الزاوية السفلى
          Container(
            padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        announcement.createdAt,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
