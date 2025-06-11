import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../models/user_model.dart';
import '../../models/following_user_model.dart';
import 'package:intl/intl.dart';

abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> fetchUserSuggestions();
  Future<UserModel> getCurrentUser();
  Future<Map<String, dynamic>> getUserById(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<FollowingUserModel>> getFollowingUsers();
  Future<List<FollowingUserModel>> getFollowersUsers();
  Future<Map<String, dynamic>> updateProfile({
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

      if (response.statusCode != 201) {
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
        '${ApiConstants.unfollowEndpoint}/$userId',
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw ServerException(data['message'] ?? 'Failed to unfollow user');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<List<FollowingUserModel>> getFollowingUsers() async {
    try {
      final response = await _apiClient.get(ApiConstants.followingEndpoint);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> usersJson = data['data'];
        return usersJson
            .map((userJson) => FollowingUserModel.fromJson(userJson))
            .toList();
      } else {
        throw ServerException(data['message'] ?? 'Failed to get following users');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<List<FollowingUserModel>> getFollowersUsers() async {
    try {
      final response = await _apiClient.get(ApiConstants.followersEndpoint);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> usersJson = data['data'];
        return usersJson
            .map((userJson) => FollowingUserModel.fromJson(userJson))
            .toList();
      } else {
        throw ServerException(data['message'] ?? 'Failed to get followers users');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
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
      final body = {
        'username': username,
        'email': email,
        'fullName': fullName,
        if (avatar != null) 'avatar': avatar,
        if (bio != null) 'bio': bio,
        if (status != null) 'status': status,
        if (isPrivate != null) 'isPrivate': isPrivate,
        if (website != null) 'website': website,
        if (location != null) 'location': location,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (gender != null) 'gender': gender,
        if (birthDate != null) 'birthDate': '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}T00:00:00.000Z',
      };

      final response = await _apiClient.put(
        ApiConstants.updateProfileEndpoint,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user'] != null) {
          return data;
        }

        throw ServerException('Invalid response format: missing user data');
      } else {
        final data = json.decode(response.body);
        print('[updateProfile] ERROR: ' + (data['message'] ?? 'Failed to update profile'));
        throw ServerException(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('[updateProfile] Exception: ' + e.toString());
      if (e is ServerException) rethrow;
      throw ServerException('Network error occurred: $e');
    }
  }
} 