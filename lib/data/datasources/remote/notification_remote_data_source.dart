import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/notification.dart';
import '../../../domain/models/notification_response.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationResponse> getNotifications({
    required int page,
    required int limit,
  });
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
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
    try {
      final response = await apiClient.get('/notifications?page=$page&limit=$limit');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return NotificationResponse.fromJson(jsonResponse);
        }
        throw ServerException('Failed to load notifications: Server returned success: false');
      }
      throw ServerException('Failed to load notifications: ${response.statusCode}');
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.put(
        '/notifications/$notificationId/read',
        body: {},
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw ServerException(data['message'] ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await apiClient.put(
        '/notifications/read-all',
        body: {},
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw ServerException(data['message'] ?? 'Failed to mark all notifications as read');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }
} 