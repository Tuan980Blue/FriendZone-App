import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  });
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.loginEndpoint,
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _apiClient.setAuthToken(data['token']);
        return data;
      } else {
        throw AuthException(data['message'] ?? 'Failed to login');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.registerEndpoint,
        body: {
          'email': email,
          'password': password,
          'username': username,
          'fullName': fullName,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        _apiClient.setAuthToken(data['token']);
        return data;
      } else {
        throw AuthException(data['message'] ?? 'Failed to register');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    _apiClient.clearAuthToken();
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
} 