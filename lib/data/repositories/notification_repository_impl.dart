import '../../domain/models/notification_response.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<NotificationResponse> getNotifications({
    required int page,
    required int limit,
  }) async {
    return await remoteDataSource.getNotifications(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // TODO: Implement mark as read functionality
    throw UnimplementedError();
  }

  @override
  Future<void> markAllAsRead() async {
    // TODO: Implement mark all as read functionality
    throw UnimplementedError();
  }
} 