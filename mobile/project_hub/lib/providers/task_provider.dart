import 'package:flutter/foundation.dart';
import 'package:project_hub/models/user_model.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

enum TaskState { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  TaskState _state = TaskState.initial;
  String? _errorMessage;
  List<Task> _tasks = [];
  List<Task> _myTaskOfProject = [];
  List<Task> _myTasks = [];
  Task? _selectedTask;

  // Getters
  TaskState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Task> get tasks => _tasks;
  List<Task> get myTasks => _myTasks;
  bool get isLoading => _state == TaskState.loading;
  Task? get selectedTask => _selectedTask;

  // Fetch my tasks
  Future<void> fetchMyTasks(
    String token, {
    Map<String, String>? queryParams,
  }) async {
    _setState(TaskState.loading);
    _errorMessage = null;
    _myTasks = [];
    try {
      final response = await TaskApiService.getMyTasks(
        token,
        queryParams: queryParams,
      );
      if (response.isSuccess) {
        _myTasks = response.model ?? [];
        _setState(TaskState.loaded);
        print('My tasks fetched successfully: ${_myTasks.length}');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch my tasks: $e');
    }
  }

  // Fetch all tasks
  Future<void> fetchAllOfProject(
    String token,
    String projectId, {
    Map<String, String>? queryParams,
  }) async {
    _setState(TaskState.loading);
    _errorMessage = null;
    _tasks = [];
    try {
      final response = await TaskApiService.getAllOfProject(
        token,
        projectId,
        queryParams: queryParams,
      );
      print('Response status: ${response.statusCode}');
      if (response.isSuccess) {
        _tasks = response.model ?? [];
        _setState(TaskState.loaded);
        print('Tasks fetched successfully: ${_tasks.length}');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch tasks: $e');
    }
  }

  // Get tasks by id
  Future<void> fetchTaskById({
    required String token,
    required String taskId,
  }) async {
    print('Fetching task by ID: $taskId');
    print('Token: $token');
    _setState(TaskState.loading);
    _errorMessage = null;
    try {
      final response = await TaskApiService.getTaskById(token, taskId);
      if (response.isSuccess) {
        _selectedTask = response.model;
        _setState(TaskState.loaded);
        print('Task fetched successfully: ${_selectedTask?.name}');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch task: $e');
    }
  }

  // Assign task to user
  Future<bool> assignTaskToMember({
    required String token,
    required String taskId,
    required String memberId,
  }) async {
    _setState(TaskState.loading);
    _errorMessage = null;
    try {
      final response = await TaskApiService.assignTaskToMember(
        token: token,
        taskId: taskId,
        memberId: memberId,
      );
      if (response.isSuccess) {
        _selectedTask = response.model;
        _tasks =
            _tasks.map((task) {
              if (task.id == taskId) {
                return _selectedTask!;
              }
              return task;
            }).toList();
        _setState(TaskState.loaded);
        print('Task assigned successfully: ${_selectedTask?.name}');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to assign task: $e');
      return false;
    }
  }

  //Unassign task from user
  Future<bool> unAssignTaskToMember({
    required String token,
    required String taskId,
    required String memberId,
  }) async {
    _setState(TaskState.loading);
    _errorMessage = null;
    try {
      final response = await TaskApiService.unAssignTaskToMember(
        token: token,
        taskId: taskId,
        memberId: memberId,
      );
      if (response.isSuccess) {
        _selectedTask = response.model;
        _tasks =
            _tasks.map((task) {
              if (task.id == taskId) {
                return _selectedTask!;
              }
              return task;
            }).toList();
        _setState(TaskState.loaded);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to unassign task: $e');
      return false;
    }
  }
  //Request task completion
  Future<bool> requestTaskCompleted({
    required String token,
    required String taskId,
  }) async {
    _setState(TaskState.loading);
    _errorMessage = null;
    try {
      final response = await TaskApiService.requestTaskCompleted(
        token: token,
        taskId: taskId,
      );
      if (response.isSuccess) {
        _selectedTask = response.model;
        _tasks =
            _tasks.map((task) {
              if (task.id == taskId) {
                return _selectedTask!;
              }
              return task;
            }).toList();
        _setState(TaskState.loaded);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to request task completion: $e');
      return false;
    }
  }
  // Confirm task completion
  Future<bool> confirmTaskCompleted({
    required String token,
    required String taskId,
    required bool confirm,
  }) async {
    _setState(TaskState.loading);
    _errorMessage = null;
    try {
      final response = await TaskApiService.confirmTaskCompleted(
        token: token,
        taskId: taskId,
        confirm: confirm,
      );
      if (response.isSuccess) {
        _selectedTask = response.model;
        _tasks =
            _tasks.map((task) {
              if (task.id == taskId) {
                return _selectedTask!;
              }
              return task;
            }).toList();
        _setState(TaskState.loaded);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to confirm task completion: $e');
      return false;
    }
  }

  // Private methods
  void _setState(TaskState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = TaskState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == TaskState.error) {
      _state = TaskState.initial;
    }
    notifyListeners();
  }
}
