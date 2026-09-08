  /// API endpoints configuration
/// Centralized location for all API endpoints
class ApiEndpoint {
  // Private constructor to prevent instantiation
  ApiEndpoint._();

  // Base URL
  // TODO: Replace with your actual base URL
  static const String baseUrl = 'https://cr-assistant-backend-1.onrender.com/api';

  // API Version
  static const String apiVersion = '/v1';

  // Full base URL with version
  static String get baseUrlWithVersion => '$baseUrl$apiVersion';

// Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String myClassCode = '/auth/my-class-code';
  static const String fcmToken = '/auth/fcm-token';

  // Semester / Subject / Resource
  static const String semesters = '/semesters';
  static String subjects(int semesterId) => '/semesters/$semesterId/subjects';
  static String addSubject(int semesterId) => '/semesters/$semesterId/subjects';
  static String deleteSubject(int subjectId) => '/subjects/$subjectId';

  static String resources(int subjectId) => '/subjects/$subjectId/resources';
  static String uploadResource(int subjectId) => '/subjects/$subjectId/resources';
  static String deleteResource(int resourceId) => '/resources/$resourceId';

  // Notice
  static const String notices = '/notices';

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
  