import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

//Annotation này đánh dấu class User là một model có thể chuyển đổi từ/đến JSON
@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String? id;
  final String username;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String role;
  final String? major;
  final String? avatar;
  final bool isActive;
  final DateTime? createdAt;

  const User({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.major,
    this.avatar,
    this.isActive = true,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  //Tạo ra một bản sao của User nhưng có thể thay đổi một vài thuộc tính
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? role,
    String? major,
    String? avatar,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      major: major ?? this.major,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
