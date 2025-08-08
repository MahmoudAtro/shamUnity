import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/models/college_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

class AcademicYearsGridScreen extends StatelessWidget {
  final List<AcademicYearModel> years;

  const AcademicYearsGridScreen({Key? key, required this.years})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السنوات الدراسية')),
      body: GridView.builder(
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
              context.pushNamed(
                RoutesNames.subjectsGrid,
                arguments: year.subjects,
              );
            },
            child: Container(
              alignment: FractionalOffset.bottomCenter,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: NetworkImage(year.imageUrl),
                //   fit: BoxFit.cover,
                // ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(year.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.sp)),
            ),
          );
        },
      ),
    );
  }
}
