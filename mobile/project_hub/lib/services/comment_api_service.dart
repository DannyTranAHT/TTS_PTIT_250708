import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/comment_model.dart';

class CommentApiService {
  // Get comments for an entity (task/project)
  static Future<ApiResponse<List<Comment>>> getComments({
    required String token,
    required String entityType,
    required String entityId,
    int page = 1,
    int limit = 20,
    String sort = 'asc',
  }) async {
    try {
      final queryParams = {
        'entity_type': entityType,
        'entity_id': entityId,
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
      };

      final uri = Uri.parse(
        '${ApiConfig.comments}',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      print('Get Comments Response Status: ${response.statusCode}');
      print('Get Comments Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response formats
        List<dynamic> commentsData;
        if (data['data'] != null && data['data']['comments'] != null) {
          commentsData = data['data']['comments'] as List;
        } else if (data['comments'] != null) {
          commentsData = data['comments'] as List;
        } else {
          commentsData = [];
        }

        final comments =
            commentsData.map((json) => Comment.fromJson(json)).toList();

        return ApiResponse.success(
          model: comments,
          message: data['message'] ?? 'Comments retrieved successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to get comments',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      print('Get Comments Error: $e');
      return ApiResponse.error(message: 'Network error: $e');
    }
  }

  // Create a new comment
  static Future<ApiResponse<Comment>> createComment({
    required String token,
    required String entityType,
    required String entityId,
    required String content,
    String? parentId,
    List<String>? attachments,
  }) async {
    try {
      final body = {
        'entity_type': entityType,
        'entity_id': entityId,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments.join(','),
      };

      final uri = Uri.parse(ApiConfig.comments);
      final response = await http.post(
        uri,
        headers: ApiConfig.authHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final comment = Comment.fromJson(data['comment']);

        return ApiResponse.success(
          model: comment,
          message: data['message'] ?? 'Comment created successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to create comment',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      print('Create Comment Error: $e');
      return ApiResponse.error(message: 'Network error: $e');
    }
  }

  // Update a comment
  static Future<ApiResponse<Comment>> updateComment({
    required String token,
    required String commentId,
    required String content,
    List<String>? attachments,
  }) async {
    try {
      final body = {
        'content': content,
        if (attachments != null) 'attachments': attachments.join(','),
      };

      final uri = Uri.parse('${ApiConfig.comments}/$commentId');
      final response = await http.put(
        uri,
        headers: ApiConfig.authHeaders(token),
        body: json.encode(body),
      );

      print('Update Comment Response Status: ${response.statusCode}');
      print('Update Comment Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final comment = Comment.fromJson(data['data']);

        return ApiResponse.success(
          model: comment,
          message: data['message'] ?? 'Comment updated successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to update comment',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      print('Update Comment Error: $e');
      return ApiResponse.error(message: 'Network error: $e');
    }
  }

  // Delete a comment
  static Future<ApiResponse<void>> deleteComment({
    required String token,
    required String commentId,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.comments}/$commentId');
      final response = await http.delete(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      print('Delete Comment Response Status: ${response.statusCode}');
      print('Delete Comment Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(
          model: null,
          message: data['message'] ?? 'Comment deleted successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to delete comment',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      print('Delete Comment Error: $e');
      return ApiResponse.error(message: 'Network error: $e');
    }
  }
}
