import 'package:flutter/material.dart';
import 'package:shamunity/feature/library/widget/add_book_widget.dart';
import 'package:shamunity/models/college_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart' show RoutesNames;

List<CollegeModel> mockColleges = [
  CollegeModel(
    id: '1',
    name: 'كلية الهندسة',
    imageUrl: 'https://i.pravatar.cc/150?img=3',
    departments: [
      DepartmentModel(
        id: '1-1',
        name: 'هندسة مدنية',
        imageUrl: 'https://i.pravatar.cc/150?img=4',
        years: [
          AcademicYearModel(
            id: '1-1-1',
            name: 'السنة الأولى',
            subjects: [
              SubjectModel(
                  id: 's1', title: 'رياضيات 1', description: 'وصف رياضيات 1'),
              SubjectModel(
                  id: 's2', title: 'فيزياء 1', description: 'وصف فيزياء 1'),
            ],
          ),
          AcademicYearModel(
            id: '1-1-2',
            name: 'السنة الثانية',
            subjects: [
              SubjectModel(
                  id: 's3', title: 'ميكانيكا', description: 'وصف ميكانيكا'),
              SubjectModel(
                  id: 's4', title: 'خرسانة', description: 'وصف خرسانة'),
            ],
          ),
        ],
      ),
      DepartmentModel(
        id: '1-2',
        name: 'هندسة كهربائية',
        imageUrl: 'https://i.pravatar.cc/150?img=5',
        years: [
          AcademicYearModel(
            id: '1-2-1',
            name: 'السنة الأولى',
            subjects: [
              SubjectModel(
                  id: 's5',
                  title: 'دوائر كهربائية',
                  description: 'وصف دوائر كهربائية'),
              SubjectModel(
                  id: 's6', title: 'الكترونيات', description: 'وصف الكترونيات'),
            ],
          ),
        ],
      ),
    ],
    description:
        'كلية الهندسة تقدم برامج دراسات هندسية متكاملة تشمل الهندسة المدنية والكهربائية.',
  ),
  CollegeModel(
    id: '2',
    name: 'كلية العلوم',
    imageUrl: 'https://i.pravatar.cc/150?img=6',
    departments: [
      DepartmentModel(
        id: '2-1',
        name: 'فيزياء',
        imageUrl: 'https://i.pravatar.cc/150?img=7',
        years: [
          AcademicYearModel(
            id: '2-1-1',
            name: 'السنة الأولى',
            subjects: [
              SubjectModel(
                  id: 's7',
                  title: 'فيزياء حديثة',
                  description: 'وصف فيزياء حديثة'),
              SubjectModel(
                  id: 's8',
                  title: 'رياضيات فيزيائية',
                  description: 'وصف رياضيات فيزيائية'),
            ],
          ),
        ],
      ),
    ],
    description:
        'كلية العلوم تهتم بدراسة العلوم الأساسية مثل الفيزياء والكيمياء والأحياء.',
  ),
];

class LibraryHomeScreen extends StatefulWidget {
  const LibraryHomeScreen({super.key});

  @override
  State<LibraryHomeScreen> createState() => _LibraryHomeScreenState();
}

class _LibraryHomeScreenState extends State<LibraryHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CollegesGridScreen(colleges: mockColleges),
    );
  }
}

class CollegesGridScreen extends StatelessWidget {
  final List<CollegeModel> colleges;

  const CollegesGridScreen({Key? key, required this.colleges})
      : super(key: key);

  void _showAddBookSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 50,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: AddBookSheet(colleges: mockColleges),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookSheet(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة كتاب', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue, // لون الزر أزرق
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: colleges.length,
        itemBuilder: (context, index) {
          final college = colleges[index];
          return GestureDetector(
            onTap: () {
              context.pushNamed(RoutesNames.departmentDetails,
                  arguments: college.departments);
            },
            child: Container(
              alignment: FractionalOffset.bottomCenter,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(college.imageUrl),
                  fit: BoxFit.cover,
                ),
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
              child: Text(college.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          );
        },
      ),
    );
  }
}
