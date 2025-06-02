import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<dynamic>> getUserSuggestions() async {
    final response = await _remoteDataSource.fetchUserSuggestions();
    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    }
    return [];
  }

  @override
  Future<User> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<User> getUserById(String userId) async {
    try {
      final response = await _remoteDataSource.getUserById(userId);
      if (response['user'] != null) {
        return User.fromJson(response['user']);
      }
      throw Exception('User not found');
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<void> followUser(String userId) async {
    await _remoteDataSource.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await _remoteDataSource.unfollowUser(userId);
  }

  @override
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
  }) async {
    try {
      final response = await _remoteDataSource.updateProfile(
        id: id,
        username: username,
        email: email,
        fullName: fullName,
        avatar: avatar,
        bio: bio,
        status: status,
        isPrivate: isPrivate,
        website: website,
        location: location,
        phoneNumber: phoneNumber,
        gender: gender,
        birthDate: birthDate,
      );
      return User.fromJson(response['user']);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
} 