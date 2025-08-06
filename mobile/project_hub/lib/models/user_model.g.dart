// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['_id'] as String?,
  username: json['username'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  role: json['role'] as String,
  major: json['major'] as String?,
  avatar: json['avatar'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'full_name': instance.fullName,
  'role': instance.role,
  'major': instance.major,
  'avatar': instance.avatar,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
};
