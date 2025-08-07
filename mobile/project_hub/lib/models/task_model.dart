import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Task {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'project_id')
  final ProjectInfo project;
  final String name;
  final String description;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  final String status;
  final String priority;
  @JsonKey(name: 'assigned_to_id')
  AssignedUser? assignedTo;
  final int hours;
  @JsonKey(name: 'attachments')
  String? attachments;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Task({
    this.id,
    required this.project,
    required this.name,
    required this.description,
    this.dueDate,
    required this.status,
    required this.priority,
    this.assignedTo,
    required this.hours,
    this.attachments,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    String? id,
    ProjectInfo? project,
    String? name,
    String? description,
    DateTime? dueDate,
    String? status,
    String? priority,
    AssignedUser? assignedToId,
    int? hours,
    String? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return Task(
      id: id ?? this.id,
      project: project ?? this.project,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedToId ?? this.assignedTo,
      hours: hours ?? this.hours,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class ProjectInfo {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String status;

  const ProjectInfo({
    required this.id,
    required this.name,
    required this.status,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) =>
      _$ProjectInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectInfoToJson(this);
}

@JsonSerializable()
class AssignedUser {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? avatar;

  const AssignedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.avatar,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) =>
      _$AssignedUserFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedUserToJson(this);
}
