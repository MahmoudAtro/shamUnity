import 'package:flutter/material.dart';
import 'package:shamunity/models/library_model.dart'
    show SemesterModel, SubjectModel;

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
                'لا توجد مواد متاحة في هذا الفصل',
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
      subtitle: Text(
        '$libraryName - $departmentName - السنة $yearNumber - الفصل ${_getSemesterName(semester)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () {
          // هنا يمكن إضافة منطق إضافة الكتاب للمادة
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إضافة كتاب للمادة: ${subject.name}'),
              backgroundColor: Colors.green,
            ),
          );
        },
        tooltip: 'إضافة كتاب',
      ),
    );
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
}
