import 'package:flutter/material.dart';
import 'package:shamunity/feature/library/library_home_screen.dart';
import 'package:shamunity/models/college_model.dart';

class SubjectsGridScreen extends StatelessWidget {
  final List<SubjectModel> subjectModel;

  const SubjectsGridScreen({Key? key, required this.subjectModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المقررات')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: subjectModel.length,
        itemBuilder: (context, index) {
          final subject = subjectModel[index];
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(subject.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(subject.description,
                      maxLines: 4, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
