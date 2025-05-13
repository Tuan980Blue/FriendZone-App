import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<User> call(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    try {
      return await repository.getUserById(userId);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }
} 