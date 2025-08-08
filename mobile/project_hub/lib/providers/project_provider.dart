import 'package:flutter/foundation.dart';
import 'package:project_hub/models/user_model.dart';
import '../models/project_model.dart';
import '../services/project_api_service.dart';

enum ProjectState { initial, loading, loaded, error }

class ProjectProvider extends ChangeNotifier {
  ProjectState _state = ProjectState.initial;
  List<Project> _projects = [];
  List<Project> _recentProjects = [];
  List<User> _members = [];
  Project? _selectedProject;
  String? _errorMessage;
  int? _numProjects;
  int? _numCompletedProjects;
  int? _numOverdueProjects;
  int? _numberInWeek;

  // Getters
  ProjectState get state => _state;
  List<Project> get projects => _projects;
  List<Project> get recentProjects => _recentProjects;
  List<User> get members => _members;
  Project? get selectedProject => _selectedProject;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProjectState.loading;
  int get numProjects => _numProjects ?? _projects.length;
  int get numCompletedProjects => _numCompletedProjects ?? 0;
  int get numOverdueProjects => _numOverdueProjects ?? 0;
  int get numberInWeek => _numberInWeek ?? 0;
  // Fetch all projects
  Future<void> fetchProjects(String token) async {
    _setState(ProjectState.loading);
    _projects.clear();
    _numProjects = 0;
    _numCompletedProjects = 0;
    _numOverdueProjects = 0;
    try {
      final response = await ProjectApiService.getProjects(token, []);
      // print('Response received: ${response.isSuccess}, ${response.message}');
      if (response.isSuccess && response.model != null) {
        _projects = response.model!;
        _numProjects = _projects.length;
        _numCompletedProjects =
            _projects.where((p) => p.status == 'Completed').length;
        _numOverdueProjects =
            _projects
                .where(
                  (p) =>
                      p.endDate != null && p.endDate!.isBefore(DateTime.now()),
                )
                .length;
        _numberInWeek =
            _projects
                .where(
                  (p) =>
                      p.startDate != null &&
                      p.startDate!.isAfter(
                        DateTime.now().subtract(Duration(days: 7)),
                      ),
                )
                .length;

        _setState(ProjectState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch projects: $e');
    }
  }

  // Fetch recent projects (3 most recent)
  Future<void> fetchRecentProjects(String token) async {
    _setState(ProjectState.loading);
    _recentProjects.clear();

    try {
      final response = await ProjectApiService.getRecentProjects(token);
      print(
        'Recent projects response received: ${response.isSuccess}, ${response.message}',
      );

      if (response.isSuccess && response.model != null) {
        _recentProjects = response.model!;
        _setState(ProjectState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch recent projects: $e');
    }
  }

  // Fetch single project
  Future<void> fetchProject(String id, String token) async {
    _setState(ProjectState.loading);

    try {
      final response = await ProjectApiService.getProject(id, token);

      if (response.isSuccess && response.model != null) {
        _selectedProject = response.model;
        _setState(ProjectState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch project: $e');
    }
  }

  // Create project
  Future<bool> createProject({
    required String token,
    required String name,
    required String description,
    required String status,
    required DateTime startDate,
    required DateTime endDate,
    required String priority,
    required double budget,
  }) async {
    try {
      final response = await ProjectApiService.createProject(
        token: token,
        name: name,
        description: description,
        status: status,
        startDate: startDate,
        endDate: endDate,
        priority: priority,
        budget: budget,
      );

      if (response.isSuccess && response.model != null) {
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to create project: $e');
      return false;
    }
  }

  // Add members to project
  Future<bool> addMemberToProject({
    required String id,
    required String token,
    required String userId,
  }) async {
    try {
      final response = await ProjectApiService.addMembersToProject(
        id: id,
        token: token,
        userId: userId,
      );
      if (response.isSuccess && response.model != null) {
        final projectIndex = _projects.indexWhere((p) => p.id == id);
        if (projectIndex != -1) {
          _projects[projectIndex] = response.model!;
        }

        if (_selectedProject?.id == id) {
          _selectedProject = response.model;
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to add members to project: $e');
      return false;
    }
  }

  //Get members of a project
  Future<void> fetchProjectMembers(String id, String token) async {
    _setState(ProjectState.loading);
    _members.clear();

    try {
      final response = await ProjectApiService.getProjectMembers(id, token);

      if (response.isSuccess && response.model != null) {
        _members = response.model!;
        _setState(ProjectState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch project members: $e');
    }
  }

  // Remove member from project
  Future<bool> removeMemberFromProject({
    required String id,
    required String token,
    required String userId,
  }) async {
    try {
      final response = await ProjectApiService.removeMemberFromProject(
        id,
        userId,
        token,
      );

      if (response.isSuccess) {
        _members.removeWhere((member) => member.id == userId);
        final projectIndex = _projects.indexWhere((p) => p.id == id);
        if (projectIndex != -1) {
          _projects[projectIndex] = response.model!;
        }
        if (_selectedProject?.id == id) {
          _selectedProject = response.model;
        }

        notifyListeners();
        return true;
      } else if (response.message ==
          'Cannot remove member with assigned tasks') {
        return false;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to remove member from project: $e');
      return false;
    }
  }

  // Update project
  Future<bool> updateProject({
    required String id,
    required String token,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await ProjectApiService.updateProject(
        id: id,
        token: token,
        data: data,
      );
      if (response.isSuccess && response.model != null) {
        final projectIndex = _projects.indexWhere((p) => p.id == id);
        if (projectIndex != -1) {
          _projects[projectIndex] = response.model!;
        }
        if (_selectedProject?.id == id) {
          _selectedProject = response.model;
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to update project: $e');
      return false;
    }
  }

  // Delete project
  Future<bool> deleteProject(String id, String token) async {
    try {
      final response = await ProjectApiService.deleteProject(id, token);

      if (response.isSuccess) {
        _projects.removeWhere((p) => p.id == id);
        if (_selectedProject?.id == id) {
          _selectedProject = null;
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete project: $e');
      return false;
    }
  }

  // Select project
  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedProject = null;
    notifyListeners();
  }

  // Private methods
  void _setState(ProjectState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = ProjectState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == ProjectState.error) {
      _state =
          _projects.isNotEmpty ? ProjectState.loaded : ProjectState.initial;
    }
    notifyListeners();
  }
}
