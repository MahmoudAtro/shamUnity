class LibraryModel {
  final int id;
  final String name;
  final List<DepartmentModel> departments;

  LibraryModel({
    required this.id,
    required this.name,
    required this.departments,
  });

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    return LibraryModel(
      id: json['id'],
      name: json['name'],
      departments: (json['departments'] as List)
          .map((dept) => DepartmentModel.fromJson(dept))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'departments': departments.map((dept) => dept.toJson()).toList(),
    };
  }
}

class DepartmentModel {
  final int id;
  final String name;
  final List<YearModel> years;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.years,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
      years: (json['years'] as List)
          .map((year) => YearModel.fromJson(year))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'years': years.map((year) => year.toJson()).toList(),
    };
  }
}

class YearModel {
  final int year;
  final List<SemesterModel> semesters;

  YearModel({
    required this.year,
    required this.semesters,
  });

  factory YearModel.fromJson(Map<String, dynamic> json) {
    return YearModel(
      year: json['year'],
      semesters: (json['semesters'] as List)
          .map((semester) => SemesterModel.fromJson(semester))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'semesters': semesters.map((semester) => semester.toJson()).toList(),
    };
  }
}

class SemesterModel {
  final String semester;
  final List<SubjectModel> subjects;

  SemesterModel({
    required this.semester,
    required this.subjects,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      semester: json['semester'],
      subjects: (json['subjects'] as List)
          .map((subject) => SubjectModel.fromJson(subject))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'subjects': subjects.map((subject) => subject.toJson()).toList(),
    };
  }
}

class SubjectModel {
  final int id;
  final String name;

  SubjectModel({
    required this.id,
    required this.name,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
