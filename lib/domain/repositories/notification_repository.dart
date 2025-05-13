import '../models/notification_response.dart';

abstract class NotificationRepository {
  Future<NotificationResponse> getNotifications({
    required int page,
    required int limit,
  });
  
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
} 