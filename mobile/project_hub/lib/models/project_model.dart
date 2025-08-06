import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class Project {
  @JsonKey(name: '_id')
  final String? id;
  final String name;
  final String description;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  final String status;
  final String priority;
  final double budget;
  @JsonKey(name: 'num_tasks')
  final int numTasks;
  @JsonKey(name: 'num_completed_tasks')
  final int numCompletedTasks;

  @JsonKey(name: 'is_archived')
  final bool isArchived;

  @JsonKey(name: 'owner_id')
  final ProjectUser? owner;

  final List<ProjectMember>? members;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Project({
    this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    required this.status,
    required this.priority,
    required this.budget,
    required this.isArchived,
    this.owner,
    this.members,
    required this.numTasks,
    required this.numCompletedTasks,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  // Helper methods to handle nullable fields
  List<ProjectMember> get safeMembers => members ?? [];
  ProjectUser? get safeOwner => owner;
  bool get hasOwner => owner != null;
  bool get hasMembers => members != null && members!.isNotEmpty;
}

@JsonSerializable()
class ProjectUser {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;

  const ProjectUser({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
  });

  factory ProjectUser.fromJson(Map<String, dynamic> json) =>
      _$ProjectUserFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectUserToJson(this);
}

@JsonSerializable()
class ProjectMember {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? role;

  const ProjectMember({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.role,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) =>
      _$ProjectMemberFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectMemberToJson(this);
}
