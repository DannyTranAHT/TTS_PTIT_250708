class Notification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final RelatedEntity? relatedEntity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedEntity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      relatedEntity:
          json['related_entity'] != null
              ? RelatedEntity.fromJson(json['related_entity'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': isRead,
      'related_entity': relatedEntity?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for updating read status
  Notification copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    RelatedEntity? relatedEntity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      relatedEntity: relatedEntity ?? this.relatedEntity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get icon based on notification type
  String get iconName {
    switch (type) {
      case 'task_assigned':
        return 'task';
      case 'task_updated':
        return 'task_update';
      case 'project_updated':
        return 'project';
      case 'comment_added':
        return 'comment';
      case 'due_date_reminder':
        return 'reminder';
      default:
        return 'notification';
    }
  }

  // Get color based on notification type
  String get typeColor {
    switch (type) {
      case 'task_assigned':
        return 'blue';
      case 'task_updated':
        return 'orange';
      case 'project_updated':
        return 'green';
      case 'comment_added':
        return 'purple';
      case 'due_date_reminder':
        return 'red';
      default:
        return 'gray';
    }
  }
}

class RelatedEntity {
  final String entityType;
  final String entityId;

  RelatedEntity({required this.entityType, required this.entityId});

  factory RelatedEntity.fromJson(Map<String, dynamic> json) {
    return RelatedEntity(
      entityType: json['entity_type'] ?? '',
      entityId: json['entity_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'entity_type': entityType, 'entity_id': entityId};
  }
}

// Response wrapper for API calls
class NotificationResponse {
  final List<Notification> notifications;
  final int totalPages;
  final int currentPage;
  final int total;
  final int unreadCount;

  NotificationResponse({
    required this.notifications,
    required this.totalPages,
    required this.currentPage,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map((item) => Notification.fromJson(item))
              .toList() ??
          [],
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      total: json['total'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
