import 'college_model.dart';

// Example usage of the college models
class CollegeModelExample {
  // Example JSON data matching your structure
  static const Map<String, dynamic> exampleJson = {
    "data": [
      {
        "id": 1,
        "name": "كلية الهندسة المعلوماتية",
        "departments": [
          {
            "id": 1,
            "name": "قسم هندسة البرمجيات",
            "years": [
              {
                "year": 1,
                "semesters": [
                  {
                    "semester": "first",
                    "subjects": [
                      {"id": 1, "name": "البرمجة 1"}
                    ]
                  }
                ]
              },
              {
                "year": 2,
                "semesters": [
                  {
                    "semester": "second",
                    "subjects": [
                      {"id": 2, "name": "قواعد البيانات"}
                    ]
                  }
                ]
              }
            ]
          },
          {"id": 2, "name": "قسم نظم المعلومات", "years": []}
        ]
      },
      {
        "id": 2,
        "name": "كلية الآداب والعلوم الإنسانية",
        "departments": [
          {"id": 3, "name": "قسم اللغة الإنجليزية", "years": []}
        ]
      },
      {"id": 3, "name": "كلية العلوم", "departments": []}
    ]
  };

  // Parse the JSON data into CollegeModel objects
  static List<LibraryModel> parseExampleData() {
    final List<dynamic> collegesData = exampleJson['data'];
    return collegesData
        .map((collegeJson) => LibraryModel.fromJson(collegeJson))
        .toList();
  }

  // Example: Get all subjects from a specific college
  static List<SubjectModel> getAllSubjectsFromCollege(LibraryModel college) {
    List<SubjectModel> subjects = [];

    for (var department in college.departments) {
      for (var year in department.years) {
        for (var semester in year.semesters) {
          subjects.addAll(semester.subjects);
        }
      }
    }

    return subjects;
  }

  // Example: Find a specific subject by name
  static SubjectModel? findSubjectByName(
      List<LibraryModel> colleges, String subjectName) {
    for (var college in colleges) {
      for (var department in college.departments) {
        for (var year in department.years) {
          for (var semester in year.semesters) {
            for (var subject in semester.subjects) {
              if (subject.name == subjectName) {
                return subject;
              }
            }
          }
        }
      }
    }
    return null;
  }

  // Example: Get all departments from all colleges
  static List<DepartmentModel> getAllDepartments(List<LibraryModel> colleges) {
    List<DepartmentModel> departments = [];
    for (var college in colleges) {
      departments.addAll(college.departments);
    }
    return departments;
  }

  // Example: Convert back to JSON
  static Map<String, dynamic> convertToJson(List<LibraryModel> colleges) {
    return {
      'data': colleges.map((college) => college.toJson()).toList(),
    };
  }
}
