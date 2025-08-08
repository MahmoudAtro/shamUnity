class ApiConstances {
  static const String _baseUrl = "https://affair-surround-mem-photographer.trycloudflare.com/api";

  /// ----------Outside Application---------

  /// Auth APIs
  static const String loginUrl = "$_baseUrl/Login";
  static const String registerUrl = "$_baseUrl/register";
  static const String verifyOtpUrl = "$_baseUrl/verify-otp";
  static const String resendOtpUrl = "$_baseUrl/resend-otp";
}
