import '../../models/notification_response.dart';
import '../../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<NotificationResponse> call({
    required int page,
    required int limit,
  }) async {
    return await repository.getNotifications(
      page: page,
      limit: limit,
    );
  }
} 