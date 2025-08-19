import 'package:flutter/material.dart';
import 'package:shamunity/feature/library/widget/image_viewer_screen.dart';
import 'package:shamunity/feature/library/widget/pdf_viewer_screen.dart';
import 'package:shamunity/feature/library/widget/text_viewer_screen.dart';
import 'package:shamunity/models/library_model.dart'
    show SemesterModel, SubjectModel, MaterialModel;

class SubjectsGridScreen extends StatelessWidget {
  final List<SemesterModel> semesters;
  final int yearNumber;
  final String departmentName;
  final String libraryName;

  const SubjectsGridScreen({
    Key? key,
    required this.semesters,
    required this.yearNumber,
    required this.departmentName,
    required this.libraryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المواد الدراسية - السنة $yearNumber'),
        centerTitle: true,
      ),
      body: semesters.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد فصول دراسية متاحة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                final semester = semesters[index];
                return SemesterCard(
                  semester: semester,
                  yearNumber: yearNumber,
                  departmentName: departmentName,
                  libraryName: libraryName,
                );
              },
            ),
    );
  }
}

class SemesterCard extends StatelessWidget {
  final SemesterModel semester;
  final int yearNumber;
  final String departmentName;
  final String libraryName;

  const SemesterCard({
    Key? key,
    required this.semester,
    required this.yearNumber,
    required this.departmentName,
    required this.libraryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Icon(
            Icons.school,
            color: Colors.purple.shade700,
          ),
        ),
        title: Text(
          'الفصل ${semester.semesterDisplayName}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          '$libraryName - $departmentName - السنة $yearNumber - الفصل ${semester.semesterDisplayName}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        children: [
          if (semester.subjects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'لا توجد مواد متاحة',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...semester.subjects.map((subject) => SubjectTile(
                  subject: subject,
                  semester: semester.semesterDisplayName,
                  yearNumber: yearNumber,
                  departmentName: departmentName,
                  libraryName: libraryName,
                )),
        ],
      ),
    );
  }
}

class SubjectTile extends StatelessWidget {
  final SubjectModel subject;
  final String semester;
  final int yearNumber;
  final String departmentName;
  final String libraryName;

  const SubjectTile({
    Key? key,
    required this.subject,
    required this.semester,
    required this.yearNumber,
    required this.departmentName,
    required this.libraryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(
          Icons.book,
          color: Colors.blue.shade700,
          size: 20,
        ),
      ),
      title: Text(
        subject.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$libraryName - $departmentName - السنة $yearNumber - الفصل ${_getSemesterName(semester)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          if (subject.materials.isNotEmpty)
            Text(
              '${subject.materials.length} مادة متاحة',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subject.materials.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () {
                _showMaterialsDialog(context);
              },
              tooltip: 'عرض المواد',
            ),
        ],
      ),
    );
  }

  void _showMaterialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مواد ${subject.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: subject.materials.isEmpty
              ? const Text('لا توجد مواد متاحة')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: subject.materials.length,
                  itemBuilder: (context, index) {
                    final material = subject.materials[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(material.status),
                          child: Icon(
                            _getMaterialIcon(material.filePath),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          material.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحالة: ${_getStatusText(material.status)}',
                              style: TextStyle(
                                color: _getStatusColor(material.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'تاريخ الإضافة: ${_formatDate(material.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: material.isApproved
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // زر عرض الملف مباشرة
                                  if (_canViewDirectly(material.filePath))
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () =>
                                          _viewMaterial(context, material),
                                      tooltip: 'عرض الملف',
                                      color: Colors.blue,
                                    ),
                                ],
                              )
                            : null,
                        onTap: material.isApproved
                            ? () => _showMaterialOptions(context, material)
                            : null,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'مقبول';
      case 'pending':
        return 'قيد المراجعة';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getMaterialIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getSemesterName(String semester) {
    switch (semester.toLowerCase()) {
      case 'first':
        return 'الأول';
      case 'second':
        return 'الثاني';
      case 'summer':
        return 'الصيفي';
      default:
        return semester;
    }
  }

  bool _canViewDirectly(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'txt'].contains(extension);
  }

  void _showMaterialOptions(BuildContext context, MaterialModel material) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('معلومات الملف'),
              subtitle:
                  Text('نوع الملف: ${_getFileTypeText(material.filePath)}'),
              onTap: () {
                Navigator.pop(context);
                _showMaterialInfo(context, material);
              },
            ),
            if (_canViewDirectly(material.filePath))
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.green),
                title: const Text('عرض الملف'),
                subtitle: const Text('عرض الملف مباشرة في التطبيق'),
                onTap: () {
                  Navigator.pop(context);
                  _viewMaterial(context, material);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showMaterialInfo(BuildContext context, MaterialModel material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
        ),
        title: Text('معلومات ${material.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('العنوان: ${material.title}'),
            const SizedBox(height: 8),
            Text('نوع الملف: ${_getFileTypeText(material.filePath)}'),
            const SizedBox(height: 8),
            Text('الحالة: ${_getStatusText(material.status)}'),
            const SizedBox(height: 8),
            Text('تاريخ الإضافة: ${_formatDate(material.createdAt)}'),
            const SizedBox(height: 8),
            Text('تاريخ التحديث: ${_formatDate(material.updatedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _viewMaterial(BuildContext context, MaterialModel material) {
    final fileExtension = material.filePath.split('.').last.toLowerCase();

    switch (fileExtension) {
      case 'pdf':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerScreen(
              fileUrl: material.filePath,
              title: material.title,
            ),
          ),
        );
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerScreen(
              imageUrl: material.filePath,
              title: material.title,
            ),
          ),
        );
        break;
      case 'txt':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextViewerScreen(
              textUrl: material.filePath,
              title: material.title,
            ),
          ),
        );
        break;
      default:
        // للملفات الأخرى، عرض رسالة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'لا يمكن عرض هذا النوع من الملفات: ${_getFileTypeText(material.filePath)}'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'إغلاق',
              onPressed: () {},
            ),
          ),
        );
    }
  }

  String _getFileTypeText(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint Presentation';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'gif':
        return 'GIF Image';
      case 'txt':
        return 'Text File';
      default:
        return 'Unknown File Type';
    }
  }
}
