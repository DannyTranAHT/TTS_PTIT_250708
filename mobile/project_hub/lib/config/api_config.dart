class ApiConfig {
  // Base URLs
  static const String baseUrl = 'http://192.168.0.103:5000/api';
  static const String socketUrl = 'http://192.168.0.103:5000';

  // Endpoints
  static const String auth = '$baseUrl/auth';
  static const String users = '$baseUrl/users';
  static const String projects = '$baseUrl/projects';
  static const String tasks = '$baseUrl/tasks';
  static const String comments = '$baseUrl/comments';
  static const String notifications = '$baseUrl/notifications';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth headers with token
  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
