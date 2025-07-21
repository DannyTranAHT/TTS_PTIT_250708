# Flutter Development Guidelines

## Table of Contents
1. [General Principles](#general-principles)
2. [Dart Language Guidelines](#dart-language-guidelines)
3. [Widget Architecture](#widget-architecture)
4. [State Management](#state-management)
5. [Project Structure](#project-structure)
6. [UI/UX Guidelines](#uiux-guidelines)
7. [Performance Optimization](#performance-optimization)
8. [Testing Guidelines](#testing-guidelines)
9. [Error Handling](#error-handling)
10. [Platform Integration](#platform-integration)
11. [Security Guidelines](#security-guidelines)
12. [Accessibility Guidelines](#accessibility-guidelines)

## General Principles

### Development Philosophy
- Follow the "Widget Everything" principle
- Prefer composition over inheritance
- Keep widgets small and focused
- Use immutable data structures
- Write declarative UI code
- Separate business logic from UI logic

### Code Quality Standards
- Use effective Dart style guidelines
- Enable and follow lint rules
- Maintain consistent formatting with `dart format`
- Write comprehensive tests
- Use meaningful names for variables and functions
- Keep methods and classes small and focused

## Dart Language Guidelines

### Variable Declaration and Naming

#### Variable Naming Conventions
```dart
// Good - Use camelCase for variables and functions
String userName = 'John Doe';
int userAge = 25;
bool isUserActive = true;

// Good - Use PascalCase for classes and enums
class UserProfile {
  final String name;
  final int age;
  
  const UserProfile({required this.name, required this.age});
}

enum UserStatus { active, inactive, pending }

// Good - Use SCREAMING_SNAKE_CASE for constants
const int MAX_RETRY_ATTEMPTS = 3;
const String API_BASE_URL = 'https://api.example.com';
```

#### Type Annotations
```dart
// Good - Use explicit types for clarity
final List<String> userNames = <String>[];
final Map<String, dynamic> userData = <String, dynamic>{};

// Good - Use var for local variables when type is obvious
var user = UserProfile(name: 'John', age: 25);
var isValid = validateUserInput(input);

// Good - Use final for immutable variables
final String appTitle = 'My Flutter App';
final DateTime createdAt = DateTime.now();
```

### Function and Method Guidelines

#### Function Structure
```dart
// Good - Function with clear parameters and return type
Future<List<User>> fetchUsers({
  required String searchTerm,
  int page = 1,
  int pageSize = 20,
}) async {
  try {
    final response = await _apiService.getUsers(
      searchTerm: searchTerm,
      page: page,
      pageSize: pageSize,
    );
    
    return response.data
        .map<User>((json) => User.fromJson(json))
        .toList();
  } catch (e) {
    throw UserFetchException('Failed to fetch users: $e');
  }
}

// Good - Extension methods for utility functions
extension StringExtension on String {
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  String get capitalized {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}
```

#### Async/Await Best Practices
```dart
// Good - Proper async/await usage
class UserService {
  Future<User> createUser(CreateUserRequest request) async {
    try {
      // Validate input
      if (!request.email.isValidEmail) {
        throw ValidationException('Invalid email format');
      }
      
      // Make API call
      final response = await _apiClient.post('/users', data: request.toJson());
      
      // Process response
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw UserCreationException('Failed to create user: $e');
    }
  }
  
  // Good - Concurrent operations
  Future<UserDashboard> loadUserDashboard(String userId) async {
    try {
      final results = await Future.wait([
        fetchUser(userId),
        fetchUserPosts(userId),
        fetchUserFollowers(userId),
      ]);
      
      return UserDashboard(
        user: results[0] as User,
        posts: results[1] as List<Post>,
        followers: results[2] as List<User>,
      );
    } catch (e) {
      throw DashboardLoadException('Failed to load dashboard: $e');
    }
  }
}
```

### Class Design

#### Immutable Data Classes
```dart
// Good - Immutable data class with copyWith
@immutable
class User {
  final String id;
  final String name;
  final String email;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
  
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      status: UserStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => UserStatus.inactive,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return Object.hash(id, name, email, status, createdAt, updatedAt);
  }
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, status: $status)';
  }
}
```

## Widget Architecture

### Widget Composition

#### Stateless Widgets
```dart
// Good - Stateless widget with clear structure
class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelectable;
  
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelectable = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildUserInfo(),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 16),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(),
      ],
    );
  }
  
  Widget _buildStatusChip() {
    final Color color = switch (user.status) {
      UserStatus.active => Colors.green,
      UserStatus.inactive => Colors.grey,
      UserStatus.pending => Colors.orange,
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.status.name.capitalized,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildUserInfo() {
    return Column(
      children: [
        _buildInfoRow('Created', _formatDate(user.createdAt)),
        if (user.updatedAt != null)
          _buildInfoRow('Updated', _formatDate(user.updatedAt!)),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
          ),
        if (onDelete != null)
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

#### Stateful Widgets
```dart
// Good - Stateful widget with proper lifecycle management
class UserForm extends StatefulWidget {
  final User? initialUser;
  final void Function(User user) onSubmit;
  
  const UserForm({
    super.key,
    this.initialUser,
    required this.onSubmit,
  });
  
  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  UserStatus _selectedStatus = UserStatus.active;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  void _initializeForm() {
    if (widget.initialUser != null) {
      _nameController.text = widget.initialUser!.name;
      _emailController.text = widget.initialUser!.email;
      _selectedStatus = widget.initialUser!.status;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildStatusDropdown(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }
  
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Name',
        hintText: 'Enter user name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }
  
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Enter email address',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!value.trim().isValidEmail) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
  
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<UserStatus>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: UserStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.name.capitalized),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }
  
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(widget.initialUser != null ? 'Update User' : 'Create User'),
    );
  }
  
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = User(
        id: widget.initialUser?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        status: _selectedStatus,
        createdAt: widget.initialUser?.createdAt ?? DateTime.now(),
        updatedAt: widget.initialUser != null ? DateTime.now() : null,
      );
      
      widget.onSubmit(user);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
```

### Custom Widgets

#### Reusable Components
```dart
// Good - Reusable loading widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  
  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Good - Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// Good - Error widget
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## State Management

### Provider Pattern
```dart
// Good - Provider-based state management
class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  
  List<User> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  final UserService _userService;
  
  UserProvider(this._userService);
  
  Future<void> loadUsers() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final users = await _userService.getAllUsers();
      _users = users;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> createUser(User user) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final newUser = await _userService.createUser(user);
      _users.add(newUser);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateUser(User user) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final updatedUser = await _userService.updateUser(user);
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _userService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

// Usage in main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(UserService()),
        ),
        // Add other providers here
      ],
      child: const MyApp(),
    ),
  );
}

// Usage in widget
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});
  
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateUserDialog(),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.users.isEmpty) {
            return const LoadingWidget(message: 'Loading users...');
          }
          
          if (userProvider.error != null) {
            return ErrorWidget(
              message: userProvider.error!,
              onRetry: () => userProvider.loadUsers(),
            );
          }
          
          if (userProvider.users.isEmpty) {
            return EmptyStateWidget(
              title: 'No users found',
              subtitle: 'Add your first user to get started',
              icon: Icons.people_outline,
              action: ElevatedButton(
                onPressed: _showCreateUserDialog,
                child: const Text('Add User'),
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => userProvider.loadUsers(),
            child: ListView.builder(
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                return UserCard(
                  user: user,
                  onEdit: () => _showEditUserDialog(user),
                  onDelete: () => _showDeleteConfirmation(user),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create User'),
        content: UserForm(
          onSubmit: (user) {
            context.read<UserProvider>().createUser(user);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
  
  void _showEditUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: UserForm(
          initialUser: user,
          onSubmit: (updatedUser) {
            context.read<UserProvider>().updateUser(updatedUser);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().deleteUser(user.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

### Bloc Pattern (Alternative)
```dart
// Good - Bloc pattern implementation
@immutable
abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class CreateUser extends UserEvent {
  final User user;
  CreateUser(this.user);
}

class UpdateUser extends UserEvent {
  final User user;
  UpdateUser(this.user);
}

class DeleteUser extends UserEvent {
  final String userId;
  DeleteUser(this.userId);
}

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  UserLoaded(this.users);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService _userService;
  
  UserBloc(this._userService) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateUser>(_onCreateUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
  }
  
  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await _userService.getAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
  
  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      try {
        final newUser = await _userService.createUser(event.user);
        final currentUsers = (state as UserLoaded).users;
        emit(UserLoaded([...currentUsers, newUser]));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    }
  }
  
  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      try {
        final updatedUser = await _userService.updateUser(event.user);
        final currentUsers = (state as UserLoaded).users;
        final updatedUsers = currentUsers.map((user) {
          return user.id == updatedUser.id ? updatedUser : user;
        }).toList();
        emit(UserLoaded(updatedUsers));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    }
  }
  
  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      try {
        await _userService.deleteUser(event.userId);
        final currentUsers = (state as UserLoaded).users;
        final updatedUsers = currentUsers.where((user) => user.id != event.userId).toList();
        emit(UserLoaded(updatedUsers));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    }
  }
}
```

## Project Structure

### Recommended Directory Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── themes/
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   ├