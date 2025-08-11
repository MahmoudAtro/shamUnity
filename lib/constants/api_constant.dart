class ApiConstances {
  static const String _baseUrl =
      "https://subscriptions-confidential-lease-savings.trycloudflare.com/api";

  static const String baseUrlImg =
      "https://subscriptions-confidential-lease-savings.trycloudflare.com";
  // static const String imageUrl = "$_baseUrl/Images/single?imagePath";

  /// ----------Outside Application---------

  /// Auth APIs
  static const String loginUrl = "$_baseUrl/login";
  static const String registerUrl = "$_baseUrl/register";
  static const String verifyOtpUrl = "$_baseUrl/verify-otp";
  static const String resendOtpUrl = "$_baseUrl/resend-otp";

  // post
  static const String postsUrl = "$_baseUrl/posts";
  static String userPosts(int userId) => '$_baseUrl/users/$userId/posts';
  static String postDetails(int postId) => '$_baseUrl/posts/$postId';
  static String postComments(int postId) => '$_baseUrl/posts/$postId/comments';
  static String commentDetails(int commentId) =>
      '$_baseUrl/comments/$commentId';

  static String addLike(int postId) => '$_baseUrl/posts/$postId/like';

  static String userFullProfile(int userId) =>
      '$_baseUrl/users/$userId/full-profile';

  // announcements
  static const String announcementsUrl = "$_baseUrl/announcements";
}
