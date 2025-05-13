import '../entities/user.dart';

abstract class UserRepository {
  Future<List<dynamic>> getUserSuggestions();
  Future<User> getCurrentUser();
  Future<User> getUserById(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
} 