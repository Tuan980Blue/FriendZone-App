class NotificationEntity {
  final String id;
  final String userId;
  final String type;
  final String content;
  final NotificationData data;
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