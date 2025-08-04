import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Task {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'projectId')
  final String projectId;
  final String name;
  final String description;
  @JsonKey(name: 'dueDate')
  final DateTime? dueDate;
  final String status;
  final String priority;
  @JsonKey(name: 'assignedToId')
  final String? assignedToId;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  const Task({
    this.id,
    required this.projectId,
    required this.name,
    required this.description,
    this.dueDate,
    required this.status,
    required this.priority,
    this.assignedToId,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    DateTime? dueDate,
    String? status,
    String? priority,
    String? assignedToId,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedToId: assignedToId ?? this.assignedToId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
