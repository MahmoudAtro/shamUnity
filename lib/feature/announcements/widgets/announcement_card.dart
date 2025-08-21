import 'package:flutter/material.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/network/download_pdf.dart';
import 'package:shamunity/feature/announcements/widgets/image_preview.dart';
import 'package:shamunity/feature/announcements/widgets/video_preview.dart';
import 'package:shamunity/models/announcement.dart';
import 'package:url_launcher/url_launcher.dart';

/// بطاقة الإعلان التي تعرض المحتوى والملفات المرفقة
/// تدعم أنواع مختلفة من الملفات:
/// - الصور: jpg, jpeg, png, gif, webp, bmp, tiff
/// - الفيديوهات: mp4, avi, mov, wmv, flv, mkv, webm, 3gp, m4v (مشاهدة مباشرة)
/// - المستندات: pdf, doc, docx, xls, xlsx, ppt, pptx, txt, rtf
/// - الأرشيف: zip, rar, 7z
/// - ملفات أخرى: يتم فتحها في التطبيق الخارجي

class AnnouncementCard extends StatefulWidget {
  final Announcement announcement;
  const AnnouncementCard({super.key, required this.announcement});

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  // دالة لفتح ملف PDF
//   void _openPDF(String pdfUrl) async {
//   try {
//     // بناء الرابط الكامل
//     final url = '${ApiConstances.baseUrlImg}/$pdfUrl';

//     // تأكد من ترميز الرابط بشكل صحيح
//     final encodedUrl = Uri.encodeFull(url);
//     final uri = Uri.parse(encodedUrl);

//     // المحاولة الأولى: فتح في تطبيق خارجي
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//       return;
//     }

//     // المحاولة الثانية: فتح باستخدام PDF.js في المتصفح
//     final browserUrl =
//         'https://mozilla.github.io/pdf.js/web/viewer.html?file=$encodedUrl';
//     final browserUri = Uri.parse(browserUrl);

//     if (await canLaunchUrl(browserUri)) {
//       await launchUrl(browserUri, mode: LaunchMode.externalApplication);
//       return;
//     }

//     // fallback: رسالة خطأ
//     debugPrint("❌ لم أتمكن من فتح ملف PDF: $url");
//   } catch (e) {
//     debugPrint("⚠️ خطأ أثناء محاولة فتح PDF: $e");
//   }
// }

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
        return HeroImageExample(
          imageUrl: fileUrl,
        );

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
        return VideoPreview(videoUrl: '${ApiConstances.baseUrlImg}$fileUrl');

      case 'pdf':
      case 'document':
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
  // Widget _buildImagePreview(BuildContext context, String imageUrl) {
  //   return GestureDetector(
  //     onTap: () => _openImageFullScreen(context, imageUrl),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: const BorderRadius.only(
  //           topLeft: Radius.circular(20),
  //           topRight: Radius.circular(20),
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.1),
  //             blurRadius: 8,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Stack(
  //         children: [
  //           ClipRRect(
  //             borderRadius: const BorderRadius.only(
  //               topLeft: Radius.circular(20),
  //               topRight: Radius.circular(20),
  //             ),
  //             child: Image.network(
  //               '${ApiConstances.baseUrlImg}/$imageUrl',
  //               width: double.infinity,
  //               height: 240,
  //               fit: BoxFit.cover,
  //               loadingBuilder: (context, child, progress) {
  //                 if (progress == null) return child;
  //                 return Container(
  //                   height: 240,
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey[100],
  //                     borderRadius: const BorderRadius.only(
  //                       topLeft: Radius.circular(20),
  //                       topRight: Radius.circular(20),
  //                     ),
  //                   ),
  //                   child: Center(
  //                     child: CircularProgressIndicator(
  //                       color: Colors.blue[500],
  //                       strokeWidth: 3,
  //                     ),
  //                   ),
  //                 );
  //               },
  //               errorBuilder: (context, error, stackTrace) => Container(
  //                 height: 240,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey[100],
  //                   borderRadius: const BorderRadius.only(
  //                     topLeft: Radius.circular(20),
  //                     topRight: Radius.circular(20),
  //                   ),
  //                 ),
  //                 child: const Center(
  //                   child: Icon(
  //                     Icons.broken_image_outlined,
  //                     color: Colors.grey,
  //                     size: 60,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           // أيقونة التكبير في الزاوية
  //           // Positioned(
  //           //   top: 12,
  //           //   right: 12,
  //           //   child: Container(
  //           //     padding: const EdgeInsets.all(8),
  //           //     decoration: BoxDecoration(
  //           //       color: Colors.black.withOpacity(0.6),
  //           //       borderRadius: BorderRadius.circular(20),
  //           //     ),
  //           //     child: const Icon(
  //           //       Icons.zoom_in,
  //           //       color: Colors.white,
  //           //       size: 20,
  //           //     ),
  //           //   ),
  //           // ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // معاينة ملف PDF
  Widget _buildPDFPreview(BuildContext context, String pdfUrl) {
    final fileName = pdfUrl.split('/').last; // استخراج اسم الملف من الرابط

    return GestureDetector(
      onTap: () => downloadPDF(context, pdfUrl),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة PDF
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: Colors.red[600],
                size: 40,
              ),
            ),
            const SizedBox(width: 12),

            // اسم الملف + وصف
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "مستند PDF",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // زر تحميل / فتح
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[500],
            ),
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
    // إذا كان الملف صورة، نعرض فقط بحجم الصورة
    if (widget.announcement.fileUrl != null &&
        ['image', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff'].contains(
            widget.announcement.fileType?.toLowerCase().replaceAll('.', ''))) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // الصورة أو الملف (بدون ظل - ستايل تيليجرام)
          if (widget.announcement.fileUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildFilePreview(
                context,
                widget.announcement.fileType!,
                widget.announcement.fileUrl!,
              ),
            ),

          // النص أسفل الصورة
          if (widget.announcement.content != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                widget.announcement.content!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),

          // التاريخ بخط صغير جدًا في الأسفل
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
                        widget.announcement.createdAt,
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
      );
    } else {
      // للملفات الأخرى، نستخدم العرض الكامل
      return IntrinsicWidth(
        child: Container(
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
              // الملف في الأعلى
              if (widget.announcement.fileUrl != null)
                _buildFilePreview(context, widget.announcement.fileType!,
                    widget.announcement.fileUrl!),

              // النص تحت الملف
              if (widget.announcement.content != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    widget.announcement.content!,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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
                            widget.announcement.createdAt,
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
        ),
      );
    }
  }
}
