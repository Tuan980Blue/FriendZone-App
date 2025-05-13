import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> fetchUserSuggestions();
  Future<UserModel> getCurrentUser();
  Future<Map<String, dynamic>> getUserById(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> fetchUserSuggestions() async {
    try {
      final response = await _apiClient.get(ApiConstants.userSuggestionsEndpoint);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerException('Failed to load suggestions: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.meEndpoint);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return UserModel.fromJson(data['user']);
      } else {
        throw AuthException(data['message'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.usersEndpoint}/$userId');
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw ServerException(data['message'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<void> followUser(String userId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.followEndpoint}/$userId',
        body: {},
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw ServerException(data['message'] ?? 'Failed to follow user');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.followEndpoint}/$userId',
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw ServerException(data['message'] ?? 'Failed to unfollow user');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }
} 