class RestPasswordModel {
  final String email;
  final String token;
  final String password;
  final String passwordConfirmation;

  RestPasswordModel({
    required this.email,
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "reset_token": token,
      "password": password,
      "password_confirmation": password
    };
  }
}

class ForgetPassword {
  final String email;

  ForgetPassword({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ForgetPasswordResponse {
  final String message;
  final String otp;

  ForgetPasswordResponse({required this.message, required this.otp});

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      message: json['message'],
      otp: json['otp'],
    );
  }
}

class CheckOtpPassword {
  final String email;
  final String otp;

  CheckOtpPassword({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {"email": email, "otp_code": otp};
  }
}

class CheckOtpPasswordResponse {
  final String message;
  final String token;

  CheckOtpPasswordResponse({required this.message, required this.token});

  factory CheckOtpPasswordResponse.fromJson(Map<String, dynamic> json) {
    return CheckOtpPasswordResponse(
      message: json['message'],
      token: json['reset_token'],
    );
  }
}
