import 'package:shamunity/constants/api_constant.dart';

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
  final int semester;
  final List<SubjectModel> subjects;

  SemesterModel({
    required this.semester,
    required this.subjects,
  });

  // Getter to convert semester number to Arabic text
  String get semesterDisplayName {
    try {
      switch (semester) {
        case 1:
          return "الفصل الأول";
        case 2:
          return "الفصل الثاني";
        default:
          return "الفصل $semester";
      }
    } catch (e) {
      // If parsing fails, return the original value
      return semester.toString();
    }
  }

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      semester: json['semester'] as int,
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
  final List<MaterialModel> materials;

  SubjectModel({
    required this.id,
    required this.name,
    required this.materials,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      name: json['name'],
      materials: (json['materials'] as List?)
              ?.map((material) => MaterialModel.fromJson(material))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'materials': materials.map((material) => material.toJson()).toList(),
    };
  }
}

class MaterialModel {
  final int id;
  final String title;
  final String filePath;
  final String status;
  final int userId;
  final int courseId;
  final int processedByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaterialModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.status,
    required this.userId,
    required this.courseId,
    required this.processedByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      title: json['title'],
      filePath: ApiConstances.baseUrlImg + json['file_url'],
      status: json['status'],
      userId: json['user_id'],
      courseId: json['course_id'],
      processedByUserId: json['processed_by_user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'status': status,
      'user_id': userId,
      'course_id': courseId,
      'processed_by_user_id': processedByUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getter to check if material is approved
  bool get isApproved => status == 'approved';

  // Helper getter to check if material is pending
  bool get isPending => status == 'pending';

  // Helper getter to check if material is rejected
  bool get isRejected => status == 'rejected';
}
