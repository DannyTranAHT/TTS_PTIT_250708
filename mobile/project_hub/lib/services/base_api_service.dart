import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';

class BaseApiService {
  static Future<ApiResponse<T>> _processResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final data = json.decode(response.body);
      if (data == null) {
        print('Response data is null');
      } else {
        print('Response data: $data');
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          model: data['data'] != null ? fromJson(data['data']) : null,
          message: data['message'] ?? 'Success',
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Unknown error occurred',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  static Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(dynamic) fromJson, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final finalUri =
          queryParams != null ? uri.replace(queryParameters: queryParams) : uri;

      final response = await http.get(
        finalUri,
        headers:
            token != null ? ApiConfig.authHeaders(token) : ApiConfig.headers,
      );

      return _processResponse(response, fromJson);
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      return ApiResponse.error(message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic) fromJson, {
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers:
            token != null ? ApiConfig.authHeaders(token) : ApiConfig.headers,
        body: json.encode(body),
      );
      return _processResponse(response, fromJson);
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      return ApiResponse.error(message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic) fromJson, {
    String? token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers:
            token != null ? ApiConfig.authHeaders(token) : ApiConfig.headers,
        body: json.encode(body),
      );

      return _processResponse(response, fromJson);
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      return ApiResponse.error(message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<T>> delete<T>(
    String endpoint,
    T Function(dynamic) fromJson, {
    String? token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers:
            token != null ? ApiConfig.authHeaders(token) : ApiConfig.headers,
      );

      return _processResponse(response, fromJson);
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      return ApiResponse.error(message: 'Network error: $e');
    }
  }
}
