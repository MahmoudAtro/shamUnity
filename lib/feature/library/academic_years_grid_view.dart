import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/feature/library/subjects_grid_screen.dart';
import 'package:shamunity/models/college_model.dart';

class AcademicYearsGridScreen extends StatelessWidget {
  final List<YearModel> years;
  final String departmentName;
  final String libraryName;

  const AcademicYearsGridScreen({
    Key? key,
    required this.years,
    required this.departmentName,
    required this.libraryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('السنوات الدراسية - $departmentName'),
        centerTitle: true,
      ),
      body: years.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد سنوات دراسية متاحة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                return GestureDetector(
                  onTap: () {
                    // التنقل لشاشة المواد الدراسية
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectsGridScreen(
                          semesters: year.semesters,
                          yearNumber: year.year,
                          departmentName: departmentName,
                          libraryName: libraryName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    alignment: FractionalOffset.bottomCenter,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'السنة ${year.year}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${year.semesters.length} فصل',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
