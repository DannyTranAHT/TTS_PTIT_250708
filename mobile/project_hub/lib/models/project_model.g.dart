// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  id: json['_id'] as String?,
  name: json['name'] as String,
  description: json['description'] as String,
  startDate:
      json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
  endDate:
      json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
  status: json['status'] as String,
  priority: json['priority'] as String,
  budget: (json['budget'] as num).toDouble(),
  isArchived: json['is_archived'] as bool,
  owner:
      json['owner_id'] == null
          ? null
          : ProjectUser.fromJson(json['owner_id'] as Map<String, dynamic>),
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => ProjectMember.fromJson(e as Map<String, dynamic>))
          .toList(),
  numTasks: (json['num_tasks'] as num).toInt(),
  numCompletedTasks: (json['num_completed_tasks'] as num).toInt(),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'status': instance.status,
  'priority': instance.priority,
  'budget': instance.budget,
  'num_tasks': instance.numTasks,
  'num_completed_tasks': instance.numCompletedTasks,
  'is_archived': instance.isArchived,
  'owner_id': instance.owner,
  'members': instance.members,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

ProjectUser _$ProjectUserFromJson(Map<String, dynamic> json) => ProjectUser(
  id: json['_id'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
);

Map<String, dynamic> _$ProjectUserToJson(ProjectUser instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'full_name': instance.fullName,
    };

ProjectMember _$ProjectMemberFromJson(Map<String, dynamic> json) =>
    ProjectMember(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$ProjectMemberToJson(ProjectMember instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'full_name': instance.fullName,
      'role': instance.role,
    };
