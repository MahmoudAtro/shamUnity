import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shamunity/models/college_model.dart' show CollegeModel, DepartmentModel, SubjectModel, AcademicYearModel;

class AddBookSheet extends StatefulWidget {
  final List<CollegeModel> colleges;

  const AddBookSheet({super.key, required this.colleges});

  @override
  State<AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends State<AddBookSheet> {
  CollegeModel? selectedCollege;
  DepartmentModel? selectedDepartment;
  AcademicYearModel? selectedYear;
  SubjectModel? selectedSubject;
  String? selectedFileName;

  void _pickFile() async {
    // استخدم file_picker
    // import 'package:file_picker/file_picker.dart';
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'إضافة كتاب',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdownCard(
              title: 'اختر الكلية',
              value: selectedCollege,
              items: widget.colleges,
              getLabel: (CollegeModel c) => c.name,
              onChanged: (value) {
                setState(() {
                  selectedCollege = value;
                  selectedDepartment = null;
                  selectedYear = null;
                  selectedSubject = null;
                });
              },
            ),
            if (selectedCollege != null)
              _buildDropdownCard(
                title: 'اختر القسم',
                value: selectedDepartment,
                items: selectedCollege!.departments,
                getLabel: (DepartmentModel d) => d.name,
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                    selectedYear = null;
                    selectedSubject = null;
                  });
                },
              ),
            if (selectedDepartment != null)
              _buildDropdownCard(
                title: 'اختر السنة',
                value: selectedYear,
                items: selectedDepartment!.years,
                getLabel: (AcademicYearModel y) => y.name,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                    selectedSubject = null;
                  });
                },
              ),
            if (selectedYear != null)
              _buildDropdownCard(
                title: 'اختر المادة',
                value: selectedSubject,
                items: selectedYear!.subjects,
                getLabel: (SubjectModel s) => s.title,
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value;
                  });
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(
                selectedFileName ?? 'اختر ملفًا',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: selectedCollege != null &&
                      selectedDepartment != null &&
                      selectedYear != null &&
                      selectedSubject != null &&
                      selectedFileName != null
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت إضافة الكتاب!')),
                      );
                    }
                  : null,
              child: const Text(
                'إضافة',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
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
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
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
}
