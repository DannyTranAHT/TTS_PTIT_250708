import '../models/user_model.dart';
import '../models/api_response.dart';
import 'base_api_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApiService {
  // Login
  static Future<ApiResponse<AuthResult>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.auth}/login');
    final response = await http.post(
      uri,
      headers: ApiConfig.headers,
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ApiResponse.success(
        model: AuthResult.fromJson(data),
        message: data['message'] ?? 'Login successful',
      );
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Register
  static Future<ApiResponse<AuthResult>> register({
    required String username,
    required String email,
    required String fullName,
    required String password,
    required String role,
    String? major,
  }) async {
    final uri = Uri.parse('${ApiConfig.auth}/register');
    final response = await http.post(
      uri,
      headers: ApiConfig.headers,
      body: json.encode({
        'username': username,
        'email': email,
        'full_name': fullName,
        'password': password,
        'role': role,
        'major': major,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return ApiResponse.success(
        model: AuthResult.fromJson(data),
        message: data['message'] ?? 'Registration successful',
      );
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Get current user profile
  static Future<ApiResponse<User>> getProfile(String token) async {
    return await BaseApiService.get(
      '${ApiConfig.auth}/profile',
      (data) => User.fromJson(data),
      token: token,
    );
  }

  //Search users by email
  static Future<ApiResponse<User>> searchUserByEmail(
    String email,
    String token,
  ) async {
    final uri = Uri.parse('${ApiConfig.users}/search/by-email?email=$email');
    final response = await http.get(uri, headers: ApiConfig.authHeaders(token));
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data['user'] == null) {
          return ApiResponse.error(message: 'No user found with this email');
        }
        final user = User.fromJson(data['user']);
        return ApiResponse.success(
          model: user,
          message: data['message'] ?? 'User found successfully',
        );
      } catch (e, stackTrace) {
        print('JSON parsing error: $e');
        print('Stack trace: $stackTrace');
        return ApiResponse.error(message: 'Failed to parse response: $e');
      }
    } else {
      print('HTTP error response: ${response.body}');
      return ApiResponse.error(
        message: 'Failed to search user: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  //Get user profile
  static Future<ApiResponse<User>> getUserProfile(String token) async {
    final uri = Uri.parse('${ApiConfig.auth}/profile');
    final response = await http.get(uri, headers: ApiConfig.authHeaders(token));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ApiResponse.success(
        model: User.fromJson(data['user']),
        message: data['message'] ?? 'User profile fetched successfully',
      );
    } else {
      return ApiResponse.error(
        message: 'Failed to fetch user profile: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Refresh token
  static Future<ApiResponse<AuthResult>> refreshToken(String token) async {
    return await BaseApiService.post(
      '${ApiConfig.auth}/refresh',
      {},
      (data) => AuthResult.fromJson(data),
      token: token,
    );
  }
}

class AuthResult {
  final String token;
  final String refreshToken;
  final String message;
  final User user;

  AuthResult({
    required this.token,
    required this.refreshToken,
    required this.message,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'],
      refreshToken: json['refreshToken'],
      message: json['message'],
      user: User.fromJson(json['user']),
    );
  }
}
