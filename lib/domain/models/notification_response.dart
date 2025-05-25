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

  NotificationResponse copyWith({
    List<NotificationEntity>? notifications,
    int? total,
    int? page,
    int? limit,
    int? totalPages,
  }) {
    return NotificationResponse(
      notifications: notifications ?? this.notifications,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;
      final notificationsList = (data['notifications'] as List)
          .map((item) => NotificationEntity.fromJson(item as Map<String, dynamic>))
          .toList();

      return NotificationResponse(
        notifications: notificationsList,
        total: (data['total'] as num?)?.toInt() ?? 0,
        page: (data['page'] as num?)?.toInt() ?? 1,
        limit: (data['limit'] as num?)?.toInt() ?? 20,
        totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      print('Error parsing notification response: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'notifications': notifications.map((n) => n.toJson()).toList(),
        'total': total,
        'page': page,
        'limit': limit,
        'totalPages': totalPages,
      }
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final T data;

  ApiResponse({
    required this.success,
    required this.data,
  });
} 