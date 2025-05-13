import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/notification.dart';
import '../../../domain/models/notification_response.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationResponse> getNotifications({
    required int page,
    required int limit,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<NotificationResponse> getNotifications({
    required int page,
    required int limit,
  }) async {
    final response = await apiClient.get('/notifications?page=$page&limit=$limit');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      
      final notifications = (data['notifications'] as List)
          .map((json) => NotificationEntity(
                id: json['id'],
                userId: json['userId'],
                type: json['type'],
                content: json['content'],
                data: NotificationData(
                  followerId: json['data']['followerId'],
                  followerUsername: json['data']['followerUsername'],
                  followerFullName: json['data']['followerFullName'],
                  followerAvatar: json['data']['followerAvatar'],
                  timestamp: DateTime.parse(json['data']['timestamp']),
                ),
                isRead: json['isRead'],
                createdAt: DateTime.parse(json['createdAt']),
                updatedAt: DateTime.parse(json['updatedAt']),
              ))
          .toList();

      return NotificationResponse(
        notifications: notifications,
        total: data['total'],
        page: data['page'],
        limit: data['limit'],
        totalPages: data['totalPages'],
      );
    } else {
      throw Exception('Failed to load notifications');
    }
  }
} 