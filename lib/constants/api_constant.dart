class ApiConstances {
  static const String _baseUrl =
      "https://tx-ping-slovenia-nc.trycloudflare.com/api";

  static const String baseUrlImg =
      "https://tx-ping-slovenia-nc.trycloudflare.com";
  // static const String imageUrl = "$_baseUrl/Images/single?imagePath";

  /// ----------Outside Application---------

  /// Auth APIs
  static const String loginUrl = "$_baseUrl/login";
  static const String registerUrl = "$_baseUrl/register";
  static const String verifyOtpUrl = "$_baseUrl/verify-otp";
  static const String resendOtpUrl = "$_baseUrl/resend-otp";
  static const String logoutUrl = "$_baseUrl/logout";
  // post
  static const String postsUrl = "$_baseUrl/posts";
  static String postsId(String userId) => '/posts/$userId';
}
