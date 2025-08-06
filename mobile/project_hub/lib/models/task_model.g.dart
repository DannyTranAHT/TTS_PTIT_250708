// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectInfo _$ProjectInfoFromJson(Map<String, dynamic> json) => ProjectInfo(
  id: json['_id'] as String,
  name: json['name'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$ProjectInfoToJson(ProjectInfo instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'status': instance.status,
    };

AssignedUser _$AssignedUserFromJson(Map<String, dynamic> json) => AssignedUser(
  id: json['_id'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$AssignedUserToJson(AssignedUser instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'full_name': instance.fullName,
      'avatar': instance.avatar,
    };

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['_id'] as String?,
  project: ProjectInfo.fromJson(json['project_id'] as Map<String, dynamic>),
  name: json['name'] as String,
  description: json['description'] as String,
  dueDate:
      json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
  status: json['status'] as String,
  priority: json['priority'] as String,
  assignedTo:
      json['assigned_to_id'] == null
          ? null
          : AssignedUser.fromJson(
            json['assigned_to_id'] as Map<String, dynamic>,
          ),
  hours: (json['hours'] as num).toInt(),
  attachments: json['attachments'] != null ? json['attachments'] as String : '',
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  '_id': instance.id,
  'project_id': instance.project,
  'name': instance.name,
  'description': instance.description,
  'due_date': instance.dueDate?.toIso8601String(),
  'status': instance.status,
  'priority': instance.priority,
  'assigned_to_id': instance.assignedTo,
  'hours': instance.hours,
  'attachments': instance.attachments,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
