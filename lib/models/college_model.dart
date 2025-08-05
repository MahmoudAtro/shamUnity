
class CollegeModel {
  final String name;
  final String id;
  final String imageUrl;
  final String description;
  final List<DepartmentModel> departments;

  CollegeModel(
      {required this.name,
      required this.id,
      required this.description,
      required this.imageUrl,
      required this.departments});
}

class DepartmentModel {
  final String id;
  final String name;
  final String imageUrl;
  final List<AcademicYearModel> years;

  DepartmentModel(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.years});
}

class SubjectModel {
  final String id;
  final String title;
  final String description;

  SubjectModel(
      {required this.id, required this.title, required this.description});
}

class AcademicYearModel {
  final String id;
  final String name;
  final List<SubjectModel> subjects;

  AcademicYearModel(
      {required this.id, required this.name, required this.subjects});
}
