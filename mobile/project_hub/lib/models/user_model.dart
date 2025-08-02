class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final String role;
  final String avatarUrl;
  final DateTime joinedDate;
  final bool isActive;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.avatarUrl = '',
    required this.joinedDate,
    this.isActive = true,
  });

  // Mock data cho demo
  static List<User> mockUsers = [
    User(
      id: '1',
      name: 'Nguyễn Văn A',
      username: 'nguyenvana',
      email: 'nguyenvana@gmail.com',
      role: 'Project Manager',
      joinedDate: DateTime.now().subtract(Duration(days: 30)),
    ),
    User(
      id: '2',
      username: 'tranthib',
      name: 'Trần Thị B',
      email: 'tranthib@gmail.com',
      role: 'Developer',
      joinedDate: DateTime.now().subtract(Duration(days: 20)),
    ),
  ];

  // Mock data để search
  static List<User> searchableUsers = [
    User(
      id: '4',
      username: 'phamthid',
      name: 'Phạm Thị D',
      email: 'phamthid@gmail.com',
      role: 'Developer',
      joinedDate: DateTime.now(),
      isActive: false,
    ),
    User(
      id: '5',
      username: 'hoangvane',
      name: 'Hoàng Văn E',
      email: 'hoangvane@gmail.com',
      role: 'Tester',
      joinedDate: DateTime.now(),
      isActive: false,
    ),
    User(
      id: '6',
      username: 'vothif',
      name: 'Võ Thị F',
      email: 'vothif@gmail.com',
      role: 'Business Analyst',
      joinedDate: DateTime.now(),
      isActive: false,
    ),
  ];
}
