import 'package:project_hub/models/user_model.dart';

import '../models/project_model.dart';
import '../models/api_response.dart';
import 'base_api_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectApiService {
  // Get all projects
  static Future<ApiResponse<List<Project>>> getProjects(
    String token,
    List<String> query,
  ) async {
    try {
      final uri = Uri.parse(ApiConfig.projects);
      if (query.isNotEmpty) {
        final queryParams = {'query': query.join(',')};
        uri.replace(queryParameters: queryParams);
      }
      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return ApiResponse.error(message: 'Empty response from server');
        }
        try {
          final data = json.decode(response.body);
          if (data['projects'] == null) {
            return ApiResponse.error(message: 'No projects data in response');
          }
          List<Project> projects = [];
          final projectsData = data['projects'] as List;
          for (int i = 0; i < projectsData.length; i++) {
            try {
              final projectJson = projectsData[i];

              // Validate project data before parsing
              if (projectJson == null) {
                print('Skipping null project at index $i');
                continue;
              }

              if (projectJson is! Map<String, dynamic>) {
                print(
                  'Skipping invalid project data at index $i: ${projectJson.runtimeType}',
                );
                continue;
              }

              // Additional validation for critical fields
              if (projectJson['name'] == null) {
                print('Skipping project with null name at index $i');
                continue;
              }

              final project = Project.fromJson(projectJson);
              projects.add(project);
            } catch (e, stackTrace) {
              print('Error parsing project at index $i: $e');
              print('Stack trace: $stackTrace');
              // Continue parsing other projects instead of failing completely
              continue;
            }
          }

          return ApiResponse.success(
            model: projects,
            message: data['message'] ?? 'Projects fetched successfully',
          );
        } catch (e, stackTrace) {
          print('JSON parsing error: $e');
          print('Stack trace: $stackTrace');

          return ApiResponse.error(message: 'Failed to parse response: $e');
        }
      } else {
        print('HTTP error response: ${response.body}');
        return ApiResponse.error(
          message: 'Failed to fetch projects: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print('Network error: $e');
      print('Stack trace: $stackTrace');
      return ApiResponse.error(message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<List<Project>>> getRecentProjects(
    String token,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.projects}/recent');
      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return ApiResponse.error(message: 'Empty response from server');
        }

        try {
          final data = json.decode(response.body);

          if (data['projects'] == null) {
            return ApiResponse.error(message: 'No projects data in response');
          }

          List<Project> projects = [];
          final projectsData = data['projects'] as List;

          for (int i = 0; i < projectsData.length; i++) {
            try {
              final projectJson = projectsData[i];

              // Validate project data before parsing
              if (projectJson == null) {
                print('Skipping null recent project at index $i');
                continue;
              }

              if (projectJson is! Map<String, dynamic>) {
                print(
                  'Skipping invalid recent project data at index $i: ${projectJson.runtimeType}',
                );
                continue;
              }

              // Additional validation for critical fields
              if (projectJson['name'] == null) {
                print('Skipping recent project with null name at index $i');
                continue;
              }

              final project = Project.fromJson(projectJson);
              projects.add(project);
            } catch (e, stackTrace) {
              print('Error parsing recent project at index $i: $e');
              print('Stack trace: $stackTrace');
              continue;
            }
          }

          return ApiResponse.success(
            model: projects,
            message: data['message'] ?? 'Recent projects fetched successfully',
          );
        } catch (e, stackTrace) {
          print('JSON parsing error: $e');
          print('Stack trace: $stackTrace');
          return ApiResponse.error(message: 'Failed to parse response: $e');
        }
      } else {
        print('HTTP error response: ${response.body}');
        return ApiResponse.error(
          message: 'Failed to fetch recent projects: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print('Network error: $e');
      print('Stack trace: $stackTrace');
      return ApiResponse.error(message: 'Network error: $e');
    }
  }

  // Get project by ID
  static Future<ApiResponse<Project>> getProject(
    String id,
    String token,
  ) async {
    final uri = Uri.parse('${ApiConfig.projects}/$id');
    final response = await http.get(uri, headers: ApiConfig.authHeaders(token));
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return ApiResponse.error(message: 'Empty response from server');
      }
      try {
        final data = json.decode(response.body);
        if (data['project'] == null) {
          return ApiResponse.error(message: 'No project data in response');
        }
        final project = Project.fromJson(data['project']);
        return ApiResponse.success(
          model: project,
          message: data['message'] ?? 'Project fetched successfully',
        );
      } catch (e, stackTrace) {
        print('JSON parsing error: $e');
        print('Stack trace: $stackTrace');
        return ApiResponse.error(message: 'Failed to parse response: $e');
      }
    } else {
      print('HTTP error response: ${response.body}');
      return ApiResponse.error(
        message: 'Failed to fetch project: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Create project
  static Future<ApiResponse<Project>> createProject({
    required String token,
    required String name,
    required String description,
    required String status,
    required DateTime startDate,
    required DateTime endDate,
    required String priority,
    required double budget,
  }) async {
    final uri = Uri.parse(ApiConfig.projects);
    final body = {
      'name': name,
      'description': description,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'priority': priority,
      'budget': budget,
    };
    final response = await http.post(
      uri,
      headers: ApiConfig.authHeaders(token),
      body: json.encode(body),
    );
    if (response.statusCode == 201) {
      try {
        final data = json.decode(response.body);
        if (data['project'] == null) {
          return ApiResponse.error(message: 'No project data in response');
        }
        final project = Project.fromJson(data['project']);
        return ApiResponse.success(
          model: project,
          message: data['message'] ?? 'Project created successfully',
        );
      } catch (e, stackTrace) {
        print('JSON parsing error: $e');
        print('Stack trace: $stackTrace');
        return ApiResponse.error(message: 'Failed to parse response: $e');
      }
    } else {
      print('HTTP error response: ${response.body}');
      return ApiResponse.error(
        message: 'Failed to create project: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Add members to project
  static Future<ApiResponse<Project>> addMembersToProject({
    required String id,
    required String token,
    required String userId,
  }) async {
    final uri = Uri.parse('${ApiConfig.projects}/$id/members');
    final body = {'user_id': userId};
    final response = await http.post(
      uri,
      headers: ApiConfig.authHeaders(token),
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data['project'] == null) {
          return ApiResponse.error(message: 'No project data in response');
        }
        final project = Project.fromJson(data['project']);
        return ApiResponse.success(
          model: project,
          message: data['message'] ?? 'Members added successfully',
        );
      } catch (e, stackTrace) {
        print('JSON parsing error: $e');
        print('Stack trace: $stackTrace');
        return ApiResponse.error(message: 'Failed to parse response: $e');
      }
    } else {
      print('HTTP error response: ${response.body}');
      return ApiResponse.error(
        message: 'Failed to add members to project: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Get members of a project
  static Future<ApiResponse<List<User>>> getProjectMembers(
    String id,
    String token,
  ) async {
    final uri = Uri.parse('${ApiConfig.projects}/$id/members');
    final response = await http.get(uri, headers: ApiConfig.authHeaders(token));
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return ApiResponse.error(message: 'Empty response from server');
      }
      try {
        final data = json.decode(response.body);
        if (data['members'] == null) {
          return ApiResponse.error(message: 'No members data in response');
        }
        List<User> members = [];
        final membersData = data['members'] as List;
        for (var memberJson in membersData) {
          members.add(User.fromJson(memberJson));
        }
        return ApiResponse.success(
          model: members,
          message: data['message'] ?? 'Members fetched successfully',
        );
      } catch (e, stackTrace) {
        print('JSON parsing error: $e');
        print('Stack trace: $stackTrace');
        return ApiResponse.error(message: 'Failed to parse response: $e');
      }
    } else {
      print('HTTP error response: ${response.body}');
      return ApiResponse.error(
        message: 'Failed to fetch project members: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  //Remove member from project
  static Future<ApiResponse<Project>> removeMemberFromProject(
    String id,
    String userId,
    String token,
  ) async {
    final uri = Uri.parse('${ApiConfig.projects}/$id/members/$userId');
    final response = await http.delete(
      uri,
      headers: ApiConfig.authHeaders(token),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['project'] == null) {
        return ApiResponse.error(message: 'No project data in response');
      }
      final project = Project.fromJson(data['project']);
      return ApiResponse.success(
        model: project,
        message: data['message'] ?? 'Member removed successfully',
      );
    } else {
      print('HTTP error response: ${response.body}');
      return ApiResponse.error(
        message: 'Failed to remove member from project: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Update project
  static Future<ApiResponse<Project>> updateProject({
    required String id,
    required String token,
    Map<String, dynamic>? data,
  }) async {
    final uri = Uri.parse('${ApiConfig.projects}/$id');
    final response = await http.put(
      uri,
      headers: ApiConfig.authHeaders(token),
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data['project'] == null) {
          return ApiResponse.error(message: 'No project data in response');
        }
        final project = Project.fromJson(data['project']);
        return ApiResponse.success(
          model: project,
          message: data['message'] ?? 'Project updated successfully',
        );
      } catch (e, stackTrace) {
        print('JSON parsing error: $e');
        print('Stack trace: $stackTrace');
        return ApiResponse.error(message: 'Failed to parse response: $e');
      }
    } else {
      print('HTTP error response: ${response.body}');
      return ApiResponse.error(
        message: 'Failed to update project: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Delete project
  static Future<ApiResponse<void>> deleteProject(
    String id,
    String token,
  ) async {
    return await BaseApiService.delete(
      '${ApiConfig.projects}/$id',
      (data) => null,
      token: token,
    );
  }
}
