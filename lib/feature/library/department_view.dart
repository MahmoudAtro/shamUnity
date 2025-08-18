import 'package:flutter/material.dart';
import 'package:shamunity/feature/library/academic_years_grid_view.dart';
import 'package:shamunity/models/college_model.dart';

class DepartmentsGridScreen extends StatelessWidget {
  final List<DepartmentModel> departments;
  final String libraryName;

  const DepartmentsGridScreen({
    Key? key,
    required this.departments,
    required this.libraryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أقسام $libraryName'),
        centerTitle: true,
      ),
      body: departments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد أقسام متاحة',
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
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final dept = departments[index];
                return GestureDetector(
                  onTap: () {
                    // التنقل لشاشة السنوات الدراسية
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AcademicYearsGridScreen(
                          years: dept.years,
                          departmentName: dept.name,
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
                          Icons.business,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dept.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dept.years.length} سنة',
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
