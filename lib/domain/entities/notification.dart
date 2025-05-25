class NotificationEntity {
  final String id;
  final String userId;
  final String type;
  final String content;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    required this.data,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? type,
    String? content,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    try {
      DateTime createdAt;
      DateTime updatedAt;
      try {
        createdAt = DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String());
        updatedAt = DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String());
      } catch (e) {
        createdAt = DateTime.now();
        updatedAt = DateTime.now();
      }

      return NotificationEntity(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        data: json['data'] as Map<String, dynamic>? ?? {},
        isRead: json['isRead'] as bool? ?? false,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error parsing notification: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'content': content,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Helper methods to get specific data based on notification type
extension NotificationDataHelper on NotificationEntity {
  // For LIKE notifications
  String? get postId => data['postId']?.toString();
  String? get likerUsername => data['likerUsername']?.toString();
  String? get likerFullName => data['likerFullName']?.toString();

  // For FOLLOW notifications
  String? get followerId => data['followerId']?.toString();
  String? get followerUsername => data['followerUsername']?.toString();
  String? get followerFullName => data['followerFullName']?.toString();
  String? get followerAvatar => data['followerAvatar']?.toString();
  DateTime? get followerTimestamp => data['timestamp'] != null 
    ? DateTime.tryParse(data['timestamp'].toString())
    : null;

  // For COMMENT notifications
  String? get commentPostId => data['postId']?.toString();
  String? get commentId => data['commentId']?.toString();
}

class NotificationData {
  final String followerId;
  final String followerUsername;
  final String followerFullName;
  final String followerAvatar;
  final DateTime timestamp;

  NotificationData({
    required this.followerId,
    required this.followerUsername,
    required this.followerFullName,
    required this.followerAvatar,
    required this.timestamp,
  });
} 