// Export all models
// Import CollegeModel to use in helper functions
import 'package:shamunity/models/library_model.dart';

export 'announcement.dart';
export 'chat_item_model.dart';
export 'chat_model.dart';
export 'comment.dart';
export 'library_file.dart';
export 'library_model.dart';
export 'login_model.dart';
export 'post.dart';
export 'rest_password_model.dart';
export 'signup_model.dart';
export 'verify_otp_model.dart';
export 'visited_user_profile.dart';

// Helper function to parse the complete college data structure
List<LibraryModel> parseCollegesFromJson(Map<String, dynamic> json) {
  final List<dynamic> collegesData = json['data'];
  return collegesData
      .map((collegeJson) => LibraryModel.fromJson(collegeJson))
      .toList();
}

// Helper function to convert colleges back to JSON
Map<String, dynamic> collegesToJson(List<LibraryModel> colleges) {
  return {
    'data': colleges.map((college) => college.toJson()).toList(),
  };
}
