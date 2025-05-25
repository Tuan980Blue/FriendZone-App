import 'package:friendzoneapp/domain/repositories/notification_repository.dart';

class GetUnreadNotificationsCountUseCase {
  final NotificationRepository repository;

  GetUnreadNotificationsCountUseCase(this.repository);

  Future<int> call() async {
    return await repository.getUnreadCount();
  }
} 