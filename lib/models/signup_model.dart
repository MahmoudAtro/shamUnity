import 'dart:io';

class SignupModelRequest {
  final String firstName;
  final String lastName;
  final String gender;
  final String birthDay;
  final String email;
  final String password;
  final String universityId;
  final String collage;
  final String major;
  final int year;
  final File? image;

  SignupModelRequest({
    this.image,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDay,
    required this.email,
    required this.password,
    required this.universityId,
    required this.collage,
    required this.major,
    required this.year,
  });
}

class SignupResponse {
  final String message;
  final int userId;
  final String email;

  SignupResponse({
    required this.message,
    required this.userId,
    required this.email,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['message'],
      userId: json['user_id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user_id': userId,
      'email': email,
    };
  }
}
