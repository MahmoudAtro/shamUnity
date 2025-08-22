class ApiConstances {
  static const String baseUrl =
      "https://last-acoustic-acre-canal.trycloudflare.com/api";

  static const String baseUrlImg =
      "https://last-acoustic-acre-canal.trycloudflare.com";

  /// ----------Outside Application---------

  /// Auth APIs
  static const String loginUrl = "$baseUrl/login";
  static const String registerUrl = "$baseUrl/register";
  static const String verifyOtpUrl = "$baseUrl/verify-otp";
  static const String resendOtpUrl = "$baseUrl/resend-otp";
  static const String logoutUrl = "$baseUrl/logout";
  static const String forgetPassword = "$baseUrl/password/email";
  static const String checkOtpPassword = "$baseUrl/password/code/check";
  static const String restPassword = "$baseUrl/password/reset";

  // Post APIs
  static const String postsUrl = "$baseUrl/posts";

  static String userPosts(int userId) => '$baseUrl/users/$userId/posts';
  static String postDetails(int postId) => '$baseUrl/posts/$postId';
  static String postComments(int postId) => '$baseUrl/posts/$postId/comments';
  static String commentDetails(int commentId) => '$baseUrl/comments/$commentId';

  static String addLike(int postId) => '$baseUrl/posts/$postId/like';

  static String userFullProfile(int userId) =>
      '$baseUrl/users/$userId/full-profile';

  // Search API
  static const String searchUrl = "$baseUrl/users/search";

  // Library API
  static const String bookRequestsUrl = "$baseUrl/book-requests";

  static const String libraryUrl = "$baseUrl/library/tree";

  // announcements
  static const String announcementsUrl = "$baseUrl/announcements";

  // suggestion
  static const String suggestion = "$baseUrl/feedback";

  // chats single
  static const String getConversation = '$baseUrl/conversations';
  static const String addConversation = '$baseUrl/conversations';
  static String getChatMessages(int conversationId) =>
      '$baseUrl/conversations/$conversationId/messages';
  static String sendMessage(int userId) => '$baseUrl/users/$userId/messages';
  static String deleteMessage(int messageId) => '$baseUrl/messages/$messageId';
  static String readAllMessage(int conversatioId) =>
      '$baseUrl/conversations/$conversatioId/read';
  static String deleteChannel(int conversationId) =>
      '$baseUrl/conversations/$conversationId';
  static String checkConversation(int conversationId) =>
      '$baseUrl/users/$conversationId/conversation';
}
