import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';

abstract class PostRemoteDataSource {
  Future<Map<String, dynamic>> fetchPosts(int page, int limit);
  Future<Map<String, dynamic>> fetchUserSuggestions();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient _apiClient;

  PostRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> fetchPosts(int page, int limit) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.postsEndpoint}?page=$page&limit=$limit',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerException('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Network error occurred: $e');
    }
  }

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
} 