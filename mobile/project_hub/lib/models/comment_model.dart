class Comment {
  final String? id;
  final String entityType;
  final String entityId;
  final Author author;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;
  List<CommentAttachment> attachments;
  final bool isDeleted;

  Comment({
    this.id,
    required this.entityType,
    required this.entityId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    this.attachments = const [],
    this.isDeleted = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? "id",
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      author: Author.fromJson(json['user_id']),
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      parentId: json['parent_id'] ?? null,
      attachments:
          json['attachments'] != null
              ? (json['attachments'] as List)
                  .map((item) => CommentAttachment.fromJson(item))
                  .toList()
              : [],
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'user_id': author.toJson(),
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'parent_id': parentId,
      'attachments': attachments.map((item) => item.toJson()).toList(),
      'is_deleted': isDeleted,
    };
  }
}

class CommentAttachment {
  final String filename;
  final String originalName;
  final String path;
  final int size;
  final String mimetype;
  final DateTime uploadedAt;

  CommentAttachment({
    required this.filename,
    required this.originalName,
    required this.path,
    required this.size,
    required this.mimetype,
    required this.uploadedAt,
  });

  factory CommentAttachment.fromJson(Map<String, dynamic> json) {
    return CommentAttachment(
      filename: json['filename'],
      originalName: json['original_name'],
      path: json['path'],
      size: json['size'],
      mimetype: json['mimetype'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'original_name': originalName,
      'path': path,
      'size': size,
      'mimetype': mimetype,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

class Author {
  final String id;
  final String fullName;
  final String avatar;
  final String userName;

  Author({
    required this.id,
    required this.fullName,
    required this.avatar,
    required this.userName,
  });
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['_id'] ?? json['id'],
      fullName: json['full_name'],
      avatar: json['avatar'],
      userName: json['username'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'full_name': fullName,
      'avatar': avatar,
      'user_name': userName,
    };
  }
  @override
  String toString() {
    return 'Author{id: $id, fullName: $fullName, avatar: $avatar, userName: $userName}';
  }
}
