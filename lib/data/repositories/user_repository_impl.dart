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
  Future<void> followUser(String userId) async {
    await _remoteDataSource.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await _remoteDataSource.unfollowUser(userId);
  }
} 