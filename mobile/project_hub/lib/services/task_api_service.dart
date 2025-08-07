import '../models/task_model.dart';
import '../models/api_response.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskApiService {
  // Fetch my tasks
  static Future<ApiResponse<List<Task>>> getMyTasks(
    String token, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('${ApiConfig.tasks}/my');
    final finalUri =
        queryParams != null ? uri.replace(queryParameters: queryParams) : uri;

    final response = await http.get(
      finalUri,
      headers: ApiConfig.authHeaders(token),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Response data: $data');
      if (data['tasks'] == null) {
        return ApiResponse.success(model: [], message: 'No tasks found');
      } else {
        List<Task> tasks =
            (data['tasks'] as List).map((task) => Task.fromJson(task)).toList();
        print('tasks fetched: ${tasks.length}');
        return ApiResponse.success(
          model: tasks,
          message: 'Tasks fetched successfully',
        );
      }
    } else {
      final data = json.decode(response.body);
      return ApiResponse.error(
        message: data['message'] ?? 'Failed to fetch tasks',
        statusCode: response.statusCode,
      );
    }
  }

  // Fetch all tasks of a project
  static Future<ApiResponse<List<Task>>> getAllOfProject(
    String token,
    String projectId, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('${ApiConfig.tasks}/project/$projectId');
    final finalUri =
        queryParams != null ? uri.replace(queryParameters: queryParams) : uri;
    print('Final URI: $finalUri');
    final response = await http.get(
      finalUri,
      headers: ApiConfig.authHeaders(token),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Response data: $data');
      if (data['tasks'] == null) {
        return ApiResponse.success(model: [], message: 'No tasks found');
      } else {
        List<Task> tasks =
            (data['tasks'] as List).map((task) => Task.fromJson(task)).toList();
        print('Tasks fetched: ${tasks.length}');
        return ApiResponse.success(
          model: tasks,
          message: 'Tasks fetched successfully',
        );
      }
    } else {
      final data = json.decode(response.body);
      return ApiResponse.error(
        message: data['message'] ?? 'Failed to fetch tasks',
        statusCode: response.statusCode,
      );
    }
  }

  // Fetch a specific task by ID
  static Future<ApiResponse<Task>> getTaskById(
    String token,
    String taskId,
  ) async {
    final uri = Uri.parse('${ApiConfig.tasks}/$taskId');
    final response = await http.get(uri, headers: ApiConfig.authHeaders(token));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['task'] == null) {
        return ApiResponse.error(message: 'Task not found', statusCode: 404);
      } else {
        Task task = Task.fromJson(data['task']);
        return ApiResponse.success(
          model: task,
          message: 'Task fetched successfully',
        );
      }
    } else {
      final data = json.decode(response.body);
      return ApiResponse.error(
        message: data['message'] ?? 'Failed to fetch task',
        statusCode: response.statusCode,
      );
    }
  }

  // Create a new task
  static Future<ApiResponse<Task>> createTask({
    required String token,
    required String projectId,
    required String name,
    required String description,
    required DateTime dueDate,
    required String priority,
    required String estimatedHours,
  }) async {
    final uri = Uri.parse(ApiConfig.tasks);
    final response = await http.post(
      uri,
      headers: ApiConfig.authHeaders(token),
      body: json.encode({
        'project_id': projectId,
        'name': name,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'priority': priority,
        'hours': estimatedHours,
      }),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      Task task = Task.fromJson(data['task']);
      return ApiResponse.success(
        model: task,
        message: 'Task created successfully',
      );
    } else {
      final data = json.decode(response.body);
      return ApiResponse.error(
        message: data['message'] ?? 'Failed to create task',
        statusCode: response.statusCode,
      );
    }
  }

  //Assign task to user
  static Future<ApiResponse<Task>> assignTaskToMember({
    required String token,
    required String taskId,
    required String memberId,
  }) async {
    final uri = Uri.parse('${ApiConfig.tasks}/$taskId/assign');
    final response = await http.post(
      uri,
      headers: ApiConfig.authHeaders(token),
      body: json.encode({'user_id': memberId}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Task task = Task.fromJson(data['task']);
      return ApiResponse.success(
        model: task,
        message: 'Task assigned successfully',
      );
    } else {
      final data = json.decode(response.body);
      return ApiResponse.error(
        message: data['message'] ?? 'Failed to assign task',
        statusCode: response.statusCode,
      );
    }
  }

  //Unassign task from user
  static Future<ApiResponse<Task>> unAssignTaskToMember({
    required String token,
    required String taskId,
    required String memberId,
  }) async {
    final uri = Uri.parse('${ApiConfig.tasks}/$taskId/unassign');
    final response = await http.post(
      uri,
      headers: ApiConfig.authHeaders(token),
      body: json.encode({'user_id': memberId}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Task task = Task.fromJson(data['task']);
      return ApiResponse.success(
        model: task,
        message: 'Task unassigned successfully',
      );
    } else {
      final data = json.decode(response.body);
      return ApiResponse.error(
        message: data['message'] ?? 'Failed to unassign task',
        statusCode: response.statusCode,
      );
    }
  }

  //Request task completion
  static Future<ApiResponse<Task>> requestTaskCompleted({
    required String token,
    required String taskId,
  }) async {
    final uri = Uri.parse('${ApiConfig.tasks}/$taskId/request-complete');
    final response = await http.post(
      uri,
      headers: ApiConfig.authHeaders(token),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Task task = Task.fromJson(data['task']);
      return ApiResponse.success(
        model: task,
        message: 'Task completion requested successfully',
      );
    } else {
      final data = json.decode(response.body);
      return ApiResponse.error(
        message: data['message'] ?? 'Failed to request task completion',
        statusCode: response.statusCode,
      );
    }
  }

  //Confirm task completion
  static Future<ApiResponse<Task>> confirmTaskCompleted({
    required String token,
    required String taskId,
    required bool confirm,
  }) async {
    final uri = Uri.parse('${ApiConfig.tasks}/$taskId/confirm-complete');
    final response = await http.post(
      uri,
      headers: ApiConfig.authHeaders(token),
      body: json.encode({'confirm': confirm}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Task task = Task.fromJson(data['task']);
      return ApiResponse.success(
        model: task,
        message: 'Task completion status updated successfully',
      );
    } else {
      final data = json.decode(response.body);
      return ApiResponse.error(
        message: data['message'] ?? 'Failed to update task completion status',
        statusCode: response.statusCode,
      );
    }
  }
}
