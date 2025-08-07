import 'dart:io';

import '../models/user_model.dart';
import '../models/api_response.dart';
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
    final uri = Uri.parse('${ApiConfig.auth}/refresh-token');
    final response = await http.post(
      uri,
      headers: ApiConfig.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ApiResponse.success(
        model: AuthResult.fromJson(data),
        message: data['message'] ?? 'Token refreshed successfully',
      );
    } else {
      return ApiResponse.error(
        message: 'Failed to refresh token: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Upload avatar
  static Future<ApiResponse<User>> uploadAvatar({
    required File imageFile,
    required String token,
  }) async {
    try {
      // Fix URL construction
      final uploadUrl = '${ApiConfig.baseUrl}/upload/avatar';

      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(ApiConfig.authHeaders(token));

      // Add file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'avatar',
        fileStream,
        fileLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
      ;
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return ApiResponse.success(
          model: data['user'] != null ? User.fromJson(data['user']) : null,
          message: data['message'] ?? 'Avatar uploaded successfully',
        );
      } else {
        final errorData = json.decode(responseBody);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to upload avatar',
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'Upload failed: $e');
    }
  }

  // Update profile
  static Future<ApiResponse<User>> updateProfile({
    required String token,
    String? fullName,
    String? major,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.auth}/profile');
      final body = <String, dynamic>{};

      if (fullName != null) body['full_name'] = fullName;
      if (major != null) body['major'] = major;
      final response = await http.put(
        uri,
        headers: ApiConfig.authHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(
          model: User.fromJson(data['user']),
          message: data['message'] ?? 'Profile updated successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'Update failed: $e');
    }
  }

  // Change password
  static Future<ApiResponse<String>> changePassword({
    required String token,
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.users}/$userId/change-password');
      final response = await http.put(
        uri,
        headers: ApiConfig.authHeaders(token),
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(
          model: 'success',
          message: data['message'] ?? 'Password changed successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to change password',
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'Password change failed: $e');
    }
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
