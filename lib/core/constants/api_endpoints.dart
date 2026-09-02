class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://bilhikma.tech/api';

  static const String publicEntities = '/public/entities';

  static String publicEntityCategories(int entityId) =>
      '/public/entities/$entityId/categories';

  static const String login = '/login';
  static const String refreshToken = '/refresh-token';
  static const String logout = '/logout';

  static const String forgotPassword = '/forgot-password';

  static const String setNewPassword = '/reset-password';

  static const String sendPasswordOtp = '/verify-otp';

  static const String profile = '/user/profile';

  static const String profilePassword = '/user/profile/password';

  static const String myEnrollments = '/user/my-enrollments';

  static const String activeContext = '/user/active-context';

  static const String enrollments = '/user/enrollments';

  static const String subjects = '/user/subjects';

  static String subject(int categorySubjectId) =>
      '/user/subjects/$categorySubjectId';

  static const String content = '/user/content';

  static String contentDetail(int contentId) => '/user/content/$contentId';

  static String contentAccessToken(int contentId) =>
      '/user/content/$contentId/access-token';

  static String attachmentAccessToken(int contentId, int attachmentId) =>
      '/user/content/$contentId/attachments/$attachmentId/access-token';

  static String contentProgress(int contentId) =>
      '/user/content/$contentId/progress';

  static const String textbooks = '/user/textbooks';

  static String textbookDownload(int textbookId) =>
      '/user/textbooks/$textbookId/download';

  static const String mediaAlbums = '/user/media-albums';

  static String mediaAlbum(int albumId) => '/user/media-albums/$albumId';

  static String mediaAlbumItemAccessToken(int albumId, int itemId) =>
      '/user/media-albums/$albumId/items/$itemId/access-token';

  static const String liveSessions = '/user/live-sessions';

  static String liveSession(int liveSessionId) =>
      '/user/live-sessions/$liveSessionId';

  static String liveSessionAttendance(int liveSessionId) =>
      '/user/live-sessions/$liveSessionId/attendance';

  static String liveSessionHeartbeat(int liveSessionId) =>
      '/user/live-sessions/$liveSessionId/attendance/heartbeat';

  static const String notifications = '/user/notifications';

  static String notificationRead(int notificationId) =>
      '/user/notifications/$notificationId/read';

  static String protectedMedia(String mediaToken) => '/media/$mediaToken';

  static const String securityEvents = '/user/security-events';

  static const String deviceFcmToken = '/user/device/fcm-token';
}
