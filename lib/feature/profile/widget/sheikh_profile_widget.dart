import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/constants/api_constant.dart';
import 'package:shamunity/core/widgets/connection_error.dart';
import 'package:shamunity/core/widgets/reusable_tab_widget.dart';
import 'package:shamunity/feature/announcements/widgets/image_preview.dart';
import 'package:shamunity/feature/announcements/widgets/video_preview.dart';
import 'package:shamunity/feature/profile/widget/sheikh_post_widget.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_cubit.dart';
import 'package:shamunity/logic/visited_user_profile/cubit/visited_user_profile_state.dart';
import 'package:shamunity/models/conversation_model.dart';
import 'package:shamunity/models/user_message.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:url_launcher/url_launcher.dart';

class SheikhProfileWidget extends StatefulWidget {
  final int userId;

  const SheikhProfileWidget({
    super.key,
    required this.userId,
  });

  @override
  State<SheikhProfileWidget> createState() => _SheikhProfileWidgetState();
}

class _SheikhProfileWidgetState extends State<SheikhProfileWidget> {
  late VisitedUserProfileCubit visitedUserProfileCubit;
  @override
  void initState() {
    super.initState();
    visitedUserProfileCubit = context.read<VisitedUserProfileCubit>();
    visitedUserProfileCubit.getVisitedUserProfile(widget.userId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitedUserProfileCubit, VisitedUserProfileState>(
      listener: (context, state) {
        // يمكن إضافة منطق إضافي هنا إذا لزم الأمر
      },
      child: BlocBuilder<VisitedUserProfileCubit, VisitedUserProfileState>(
        builder: (context, state) {
          // استدعاء getVisitedUserProfile عند أول بناء للـ widget

          if (state is VisitedUserProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
            );
          } else if (state is VisitedUserProfileError) {
            return ConnectionError(message: state.message);
          } else if (state is VisitedUserProfileLoaded) {
            final profile = state.profile;
            final author = profile.profile;

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),

                        // الصورة الشخصية مع حافة زرقاء جميلة
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            backgroundImage: author.profilePictureUrl != null
                                ? NetworkImage(
                                    "${ApiConstances.baseUrlImg}${author.profilePictureUrl!}")
                                : const AssetImage(
                                        'assets/images/default_avatar.jpg')
                                    as ImageProvider,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // اسم المستخدم
                        Text(
                          author.name,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),

                        if (author.college != null) ...[
                          Text(
                            author.college!,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                        ],
                        if (author.major != null) ...[
                          Text(
                            author.major!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                        Text(
                          author.email,
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),

                        // زر المحادثة المصغر مع تنسيق جميل
                        SizedBox(
                          width: 200, // تصغير العرض
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.pushNamed('/userChatScreen',
                                  arguments: ConversationResponseModel(
                                    id: 0,
                                    participant: UserMessage(
                                      id: state.profile.profile.id,
                                      name: state.profile.profile.name,
                                      profilePictureUrl: state
                                          .profile.profile.profilePictureUrl,
                                    ),
                                    updatedAt: DateTime(2004),
                                  ));
                            },
                            icon: const Icon(Icons.chat_bubble_outline,
                                color: Colors.white, size: 20),
                            label: const Text(
                              'ابدأ محادثة',
                              style: TextStyle(
                                fontSize: 16, // تصغير الخط
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue, // تغيير اللون إلى الأزرق
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20), // تقليل البادينج
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    25), // حواف أكثر انسيابية
                              ),
                              elevation: 4,
                              shadowColor: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // استخدام الودجت القابلة لإعادة الاستخدام
                        PostsAndFilesTabWidget(
                          posts: profile.posts
                              .map((post) => SheikhPostWidget(
                                    post: post,
                                    author: author,
                                  ))
                              .toList(),
                          files: profile.libraryFiles
                              .map((file) => _buildEnhancedFileCard(
                                  context, file.type!, file.filePath))
                              .toList(),
                          height: 500,
                          indicatorColor: Colors.blue,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
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

  // دالة لبناء كارد الملف المحسن (مطابق لصفحة القرارات)
  Widget _buildEnhancedFileCard(
      BuildContext context, String fileType, String fileUrl) {
    // استخدام نفس التصميم من AnnouncementCard
    return _buildFilePreview(context, fileType, fileUrl);
  }

  // دالة لبن
  // معاينة ملف PDF محسنة
  Widget _buildPDFPreview(BuildContext context, String pdfUrl) {
    final fileName = pdfUrl.split('/').last;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          radius: 24,
          child: Icon(
            Icons.picture_as_pdf,
            color: Colors.red[600],
            size: 28,
          ),
        ),
        title: Text(
          fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "مستند PDF",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _showFileOptions(context,
                  {'title': fileName, 'type': 'pdf', 'fileUrl': pdfUrl}),
              tooltip: 'خيارات الملف',
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: () => _downloadPDF(context, pdfUrl),
              tooltip: 'تحميل الملف',
            ),
          ],
        ),
        onTap: () => _showFileOptions(
            context, {'title': fileName, 'type': 'pdf', 'fileUrl': pdfUrl}),
      ),
    );
  }

  // معاينة المستندات محسنة
  Widget _buildDocumentPreview(
      BuildContext context, String fileUrl, String docType) {
    IconData iconData;
    Color backgroundColor;
    String displayName;

    switch (docType) {
      case 'Word':
        iconData = Icons.description;
        backgroundColor = Colors.blue[600]!;
        displayName = 'مستند Word';
        break;
      case 'Excel':
        iconData = Icons.table_chart;
        backgroundColor = Colors.green[600]!;
        displayName = 'جدول Excel';
        break;
      case 'PowerPoint':
        iconData = Icons.slideshow;
        backgroundColor = Colors.orange[600]!;
        displayName = 'عرض PowerPoint';
        break;
      case 'Text':
        iconData = Icons.text_snippet;
        backgroundColor = Colors.grey[600]!;
        displayName = 'ملف نصي';
        break;
      default:
        iconData = Icons.insert_drive_file;
        backgroundColor = Colors.grey[600]!;
        displayName = 'مستند';
    }

    final fileName = fileUrl.split('/').last;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: backgroundColor.withOpacity(0.1),
          radius: 24,
          child: Icon(
            iconData,
            color: backgroundColor,
            size: 28,
          ),
        ),
        title: Text(
          fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: backgroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _showFileOptions(context,
                  {'title': fileName, 'type': docType, 'fileUrl': fileUrl}),
              tooltip: 'خيارات الملف',
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.orange),
              onPressed: () => _openFile(context,
                  {'title': fileName, 'type': docType, 'fileUrl': fileUrl}),
              tooltip: 'فتح الملف',
            ),
          ],
        ),
        onTap: () => _showFileOptions(
            context, {'title': fileName, 'type': docType, 'fileUrl': fileUrl}),
      ),
    );
  }

  // معاينة ملفات الأرشيف محسنة
  Widget _buildArchivePreview(
      BuildContext context, String fileUrl, String archiveType) {
    IconData iconData;
    Color backgroundColor;
    String displayName;

    switch (archiveType) {
      case 'zip':
        iconData = Icons.archive;
        backgroundColor = Colors.orange[600]!;
        displayName = 'ملف ZIP';
        break;
      case 'rar':
        iconData = Icons.archive;
        backgroundColor = Colors.red[600]!;
        displayName = 'ملف RAR';
        break;
      case '7z':
        iconData = Icons.archive;
        backgroundColor = Colors.purple[600]!;
        displayName = 'ملف 7Z';
        break;
      default:
        iconData = Icons.archive;
        backgroundColor = Colors.grey[600]!;
        displayName = 'ملف أرشيف';
    }

    final fileName = fileUrl.split('/').last;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: backgroundColor.withOpacity(0.1),
          radius: 24,
          child: Icon(
            iconData,
            color: backgroundColor,
            size: 28,
          ),
        ),
        title: Text(
          fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: backgroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _showFileOptions(context,
                  {'title': fileName, 'type': 'أرشيف', 'fileUrl': fileUrl}),
              tooltip: 'خيارات الملف',
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: () => _openFile(context,
                  {'title': fileName, 'type': 'أرشيف', 'fileUrl': fileUrl}),
              tooltip: 'تحميل الأرشيف',
            ),
          ],
        ),
        onTap: () => _showFileOptions(
            context, {'title': fileName, 'type': 'أرشيف', 'fileUrl': fileUrl}),
      ),
    );
  }

  // معاينة الملفات العامة محسنة
  Widget _buildGenericFilePreview(
      BuildContext context, String fileUrl, String fileType) {
    final fileName = fileUrl.split('/').last;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          radius: 24,
          child: Icon(
            Icons.insert_drive_file,
            color: Colors.grey[600],
            size: 28,
          ),
        ),
        title: Text(
          fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                fileType.isNotEmpty ? fileType : 'ملف عام',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _showFileOptions(context,
                  {'title': fileName, 'type': fileType, 'fileUrl': fileUrl}),
              tooltip: 'خيارات الملف',
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.orange),
              onPressed: () => _openFile(context,
                  {'title': fileName, 'type': fileType, 'fileUrl': fileUrl}),
              tooltip: 'فتح الملف',
            ),
          ],
        ),
        onTap: () => _showFileOptions(
            context, {'title': fileName, 'type': fileType, 'fileUrl': fileUrl}),
      ),
    );
  }

  // دالة لعرض خيارات الملف (مطابقة لـ AnnouncementCard)
  void _showFileOptions(BuildContext context, dynamic file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // مقبض السحب
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // عنوان الملف
              Text(
                file['title'] ?? file.title ?? 'ملف',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // نوع الملف
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  file['type'] ?? file.type ?? 'غير محدد',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // خيارات الملف
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.info, color: Colors.white),
                ),
                title: const Text('معلومات الملف'),
                subtitle: Text(
                    'عرض تفاصيل ${file['title'] ?? file.title ?? 'الملف'}'),
                onTap: () {
                  Navigator.pop(context);
                  _showFileInfo(context, file);
                },
              ),

              if (_canViewDirectly(file['fileUrl'] ?? file.fileUrl ?? ''))
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.visibility, color: Colors.white),
                  ),
                  title: const Text('عرض الملف'),
                  subtitle: const Text('عرض الملف مباشرة في التطبيق'),
                  onTap: () {
                    Navigator.pop(context);
                    _viewFile(
                        context,
                        file['fileUrl'] ?? file.fileUrl ?? '',
                        file['title'] ?? file.title ?? '',
                        file['type'] ?? file.type ?? '');
                  },
                ),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.open_in_new, color: Colors.orange),
                ),
                title: const Text('فتح خارجياً'),
                subtitle: const Text('فتح الملف في تطبيق خارجي'),
                onTap: () {
                  Navigator.pop(context);
                  _openFile(context, file);
                },
              ),

              if ((file['type'] ?? file.type ?? '')
                  .toLowerCase()
                  .contains('pdf'))
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.download, color: Colors.white),
                  ),
                  title: const Text('تحميل الملف'),
                  subtitle: const Text('تحميل الملف على الجهاز'),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadPDF(
                        context, file['fileUrl'] ?? file.fileUrl ?? '');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة للتحقق من إمكانية عرض الملف مباشرة
  bool _canViewDirectly(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'txt', 'image']
        .contains(extension);
  }

  // دالة لعرض الملف مباشرة
  void _viewFile(
      BuildContext context, String fileUrl, String fileName, String fileType) {
    final extension = fileUrl.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        // يمكن إضافة PDF viewer هنا
        _downloadPDF(context, fileUrl);
        break;

      default:
        _openFile(
            context, {'title': fileName, 'type': fileType, 'fileUrl': fileUrl});
    }
  }

  // دالة لعرض معلومات الملف
  void _showFileInfo(BuildContext context, dynamic file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('معلومات الملف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('اسم الملف:', file['title'] ?? file.title ?? 'ملف'),
            const SizedBox(height: 8),
            _buildInfoRow(
                'نوع الملف:', file['type'] ?? file.type ?? 'غير محدد'),
            const SizedBox(height: 8),
            _buildInfoRow('الرابط:',
                (file['fileUrl'] ?? file.fileUrl ?? '').split('/').last),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  // دالة لتحميل الملف
  void _downloadFile(BuildContext context, dynamic file) {
    // هنا يمكن إضافة منطق التحميل
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('جاري تحميل ${file['title'] ?? file.title ?? 'الملف'}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // دالة لفتح أي ملف حسب نوعه (مطابقة لـ AnnouncementCard)
  void _openFile(BuildContext context, dynamic file) async {
    final fileUrl = file['fileUrl'] ?? file.fileUrl ?? '';
    final fileType = file['type'] ?? file.type ?? '';

    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رابط الملف غير متوفر'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
              onPressed: () => _openFile(context, file),
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
            onPressed: () => _openFile(context, file),
          ),
        ),
      );
    }
  }

  // دالة لتحميل PDF
  void _downloadPDF(BuildContext context, String pdfUrl) {
    // هنا يمكن إضافة منطق تحميل PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تحميل ${pdfUrl.split('/').last}...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
