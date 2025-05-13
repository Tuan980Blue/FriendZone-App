import '../entities/notification.dart';

class NotificationResponse {
  final List<NotificationEntity> notifications;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  NotificationResponse({
    required this.notifications,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class ApiResponse<T> {
  final bool success;
  final T data;

  ApiResponse({
    required this.success,
    required this.data,
  });
} 