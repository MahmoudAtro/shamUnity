class ApiConstances {
  static const String _baseUrl =
      "https://adoption-nano-glucose-gerald.trycloudflare.com/api";

  static const String baseUrlImg =
      "https://adoption-nano-glucose-gerald.trycloudflare.com";
  // static const String imageUrl = "$_baseUrl/Images/single?imagePath";

  /// ----------Outside Application---------

  /// Auth APIs
  static const String loginUrl = "$_baseUrl/login";
  static const String registerUrl = "$_baseUrl/register";
  static const String verifyOtpUrl = "$_baseUrl/verify-otp";
  static const String resendOtpUrl = "$_baseUrl/resend-otp";
  static const String logoutUrl = "$_baseUrl/logout";
  static const String forgetPassword = "$_baseUrl/password/email";
  static const String checkOtpPassword = "$_baseUrl/password/code/check";
  static const String restPassword = "$_baseUrl/password/reset";

  // Post APIs
  static const String postsUrl = "$_baseUrl/posts";
  static String userPosts(int userId) => '$_baseUrl/users/$userId/posts';
  static String postDetails(int postId) => '$_baseUrl/posts/$postId';
  static String postComments(int postId) => '$_baseUrl/posts/$postId/comments';
  static String commentDetails(int commentId) =>
      '$_baseUrl/comments/$commentId';

  static String addLike(int postId) => '$_baseUrl/posts/$postId/like';

  static String userFullProfile(int userId) =>
      '$_baseUrl/users/$userId/full-profile';

  // Search API
  static const String searchUrl = "$_baseUrl/users/search";

  // announcements
  static const String announcementsUrl = "$_baseUrl/announcements";
}
