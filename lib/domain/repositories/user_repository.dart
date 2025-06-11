import '../entities/user.dart';
import '../entities/following_user.dart';

abstract class UserRepository {
  Future<List<dynamic>> getUserSuggestions();
  Future<User> getCurrentUser();
  Future<User> getUserById(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<FollowingUser>> getFollowingUsers();
  Future<List<FollowingUser>> getFollowersUsers();
  Future<User> updateProfile({
    required String id,
    required String username,
    required String email,
    required String fullName,
    String? avatar,
    String? bio,
    String? status,
    bool? isPrivate,
    String? website,
    String? location,
    String? phoneNumber,
    String? gender,
    DateTime? birthDate,
  });
} 