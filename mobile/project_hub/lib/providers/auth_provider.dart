import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/storage_service.dart';
import '../services/socket_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _token;
  String? _refreshToken;
  String? _errorMessage;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _token != null;
  bool get isLoading => _state == AuthState.loading;

  // Initialize provider (check if user is already logged in)
  Future<void> initializeAuth() async {
    _setState(AuthState.loading);

    try {
      final savedToken = await StorageService.getToken();
      final savedUser = await StorageService.getUser();

      if (savedToken != null && savedUser != null) {
        // Verify token with backend
        final response = await AuthApiService.getProfile(savedToken);

        if (response.isSuccess && response.model != null) {
          _token = savedToken;
          _setState(AuthState.authenticated);

          // Connect socket
          SocketService.instance.connect(savedToken);
        } else {
          // Token is invalid, clear storage
          await _clearUserData();
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    }
  }

  // Login
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      final response = await AuthApiService.login(
        username: username,
        password: password,
      );

      if (response.isSuccess && response.model != null) {
        _token = response.model!.token;
        _refreshToken = response.model!.refreshToken;
        _user = response.model!.user;

        // Save to storage
        await StorageService.saveToken(_token!);
        await StorageService.saveRefreshToken(_refreshToken!);
        await StorageService.saveUser(_user!);

        _setState(AuthState.authenticated);

        // Connect socket
        SocketService.instance.connect(_token!);

        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String fullName,
    required String password,
    required String role,
    String? major,
  }) async {
    _setState(AuthState.loading);

    try {
      final response = await AuthApiService.register(
        username: username,
        email: email,
        fullName: fullName,
        password: password,
        role: role,
        major: major,
      );

      if (response.isSuccess && response.model != null) {
        // Save to storage
        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_user!);

        _setState(AuthState.authenticated);

        // Connect socket
        SocketService.instance.connect(_token!);

        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      // Disconnect socket
      SocketService.instance.disconnect();

      // Clear storage
      await _clearUserData();

      _token = null;
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Logout failed: $e');
    }
  }

  //Search user by email
  Future<User?> searchUserByEmail(String email) async {
    try {
      final response = await AuthApiService.searchUserByEmail(email, _token!);
      if (response.isSuccess && response.model != null) {
        return response.model;
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      _setError('Failed to search user: $e');
      return null;
    }
  }

  // Get user profile
  Future<void> getUserProfile() async {
    _setState(AuthState.loading);
    try {
      final response = await AuthApiService.getUserProfile(_token!);
      if (response.isSuccess && response.model != null) {
        _user = response.model;
        print('User profile fetched: ${_user?.fullName}');
        notifyListeners();
        _setState(AuthState.authenticated);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch user profile: $e');
    }
  }

  // Update user profile
  void updateUser(User updatedUser) {
    _user = updatedUser;
    StorageService.saveUser(updatedUser);
    notifyListeners();
  }

  // Private methods
  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> _clearUserData() async {
    await StorageService.removeToken();
    await StorageService.removeUser();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state =
          _token != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
