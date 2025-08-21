import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/logic/library%20bloc/library_cubit.dart';
import 'package:shamunity/logic/library%20bloc/library_state.dart';
import 'package:shamunity/models/book_request.dart';
import 'package:shamunity/models/library_model.dart'
    show LibraryModel, DepartmentModel, YearModel, SemesterModel;
import 'package:shamunity/routes/extension.dart';

class AddBookSheet extends StatefulWidget {
  final List<LibraryModel> libraries;

  const AddBookSheet({super.key, required this.libraries});

  @override
  State<AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends State<AddBookSheet> {
  LibraryModel? selectedLibrary;
  DepartmentModel? selectedDepartment;
  YearModel? selectedYear;
  SemesterModel? selectedSemester;
  String? selectedFileName;
  File? selectedFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'jpg',
        'jpeg',
        'png',
        'gif'
      ],
    );
    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryCubit, LibraryState>(
      listener: (context, state) {
        if (state is UploadFileSuccess) {
          context.pop();
          Toast().success(context, 'تم رفع الكتاب بنجاح');
        } else if (state is UploadFileFailure) {
          Toast().error(context, 'فشل في رفع الكتاب: ${state.message}');
        }
      },
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.library_books,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إضافة كتاب جديد',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'اختر القسم والمادة ثم ارفع الملف',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selection Fields
                      _buildSelectionSection(),
                      const SizedBox(height: 24),
                      // File Upload Section
                      _buildFileSelectionSection(),
                      const SizedBox(height: 24),
                      // Upload Button
                      _buildUploadButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard<T>({
    required String title,
    required T? value,
    required List<T> items,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: DropdownButtonFormField<T>(
          decoration: InputDecoration(
            labelText: title,
            border: InputBorder.none,
          ),
          isExpanded: true,
          value: value,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(getLabel(item)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.blue[600],
            size: 22,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue[600]!,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختيار المادة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),

        _buildDropdownCard(
          title: 'اختر القسم',
          value: selectedLibrary,
          items: widget.libraries,
          getLabel: (LibraryModel l) => l.name,
          onChanged: (value) {
            setState(() {
              selectedLibrary = value;
              selectedDepartment = null;
              selectedYear = null;
              selectedSemester = null;
            });
          },
        ),
        if (selectedLibrary != null) ...[
          _buildDropdownCard(
            title: 'اختر القسم الفرعي',
            value: selectedDepartment,
            items: selectedLibrary!.departments,
            getLabel: (DepartmentModel d) => d.name,
            onChanged: (value) {
              setState(() {
                selectedDepartment = value;
                selectedYear = null;
                selectedSemester = null;
              });
            },
          ),
        ],
        if (selectedDepartment != null) ...[
          _buildDropdownCard(
            title: 'اختر السنة',
            value: selectedYear,
            items: selectedDepartment!.years,
            getLabel: (YearModel y) => y.year.toString(),
            onChanged: (value) {
              setState(() {
                selectedYear = value;
                selectedSemester = null;
              });
            },
          ),
        ],
        if (selectedYear != null) ...[
          _buildDropdownCard(
            title: 'اختر الفصل',
            value: selectedSemester,
            items: selectedYear!.semesters,
            getLabel: (SemesterModel s) => s.semesterDisplayName,
            onChanged: (value) {
              setState(() {
                selectedSemester = value;
              });
            },
          ),
        ],
        const SizedBox(height: 16),
        // Title and Description Fields
        Text(
          'معلومات الملف',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _titleController,
          label: 'عنوان الملف',
          hint: 'مثال: محاضرة الأسبوع الأول - البرمجة',
          icon: Icons.title,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'وصف الملف (اختياري)',
          hint: 'مثال: محاضرة تتحدث عن أساسيات البرمجة',
          icon: Icons.description,
          maxLines: 2,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildFileSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.upload_file,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'اختيار الملف',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (selectedFile != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedFileName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'تم اختيار الملف بنجاح',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedFileName = null;
                        selectedFile = null;
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.red[400],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selectedFile != null ? Colors.grey[400] : Colors.blue[600],
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: selectedFile != null ? null : _pickFile,
            icon: Icon(
              selectedFile != null ? Icons.check : Icons.attach_file,
              size: 20,
            ),
            label: Text(
              selectedFile != null ? 'تم اختيار الملف' : 'اختر ملفًا',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الملفات المدعومة: PDF, Word, Excel, PowerPoint, نص, صور',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // String _getFileType(String fileName) {
  //   final extension = fileName.split('.').last.toLowerCase();
  //   switch (extension) {
  //     case 'pdf':
  //       return 'pdf';
  //     case 'doc':
  //     case 'docx':
  //       return 'doc';
  //     case 'xls':
  //     case 'xlsx':
  //       return 'xls';
  //     case 'ppt':
  //     case 'pptx':
  //       return 'ppt';
  //     case 'txt':
  //       return 'txt';
  //     case 'jpg':
  //     case 'jpeg':
  //       return 'image';
  //     case 'png':
  //       return 'image';
  //     case 'gif':
  //       return 'image';
  //     default:
  //       return 'other';
  //   }
  // }

  Widget _buildUploadButton() {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final isLoading = state is UploadFileLoading;

        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isLoading
                  ? [Colors.grey[400]!, Colors.grey[500]!]
                  : [Colors.blue[600]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: (selectedLibrary != null &&
                    selectedDepartment != null &&
                    selectedYear != null &&
                    selectedSemester != null &&
                    selectedFile != null &&
                    _titleController.text.trim().isNotEmpty &&
                    !isLoading)
                ? () {
                    context.read<LibraryCubit>().uploadBook(BookRequestModel(
                          title: _titleController.text.trim(),
                          courseId: selectedYear!.year,
                          file: selectedFile,
                        ));
                  }
                : null,
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'جاري الرفع...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'رفع الملف',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
