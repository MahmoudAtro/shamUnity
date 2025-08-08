class VerifyOtpRequest {
  final String email;
  final String otpCode;

  VerifyOtpRequest({
    required this.email,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp_code': otpCode,
    };
  }
}

class VerifyOtpResponse {
  final String message;
  final String token;
  final UserModel user;

  VerifyOtpResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'user': user.toJson(),
    };
  }
}

class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String birthDate;
  final String universityId;
  final String college;
  final String major;
  final String year;
  final String role;
  final int id;
  final String? profilePictureUrl;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.universityId,
    required this.college,
    required this.major,
    required this.year,
    required this.role,
    required this.id,
    this.profilePictureUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      universityId: json['university_id'] ?? '',
      college: json['college'] ?? '',
      major: json['major'] ?? '',
      year: json['year'] ?? '',
      role: json['role'] ?? '',
      id: json['id'] ?? 0,
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'gender': gender,
      'birth_date': birthDate,
      'university_id': universityId,
      'college': college,
      'major': major,
      'year': year,
      'role': role,
      'id': id,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

class ResendOtpRequest {
  final String email;

  ResendOtpRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResendOtpResponse {
  final String message;

  ResendOtpResponse({required this.message});

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
