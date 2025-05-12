import 'dart:convert';
import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

abstract class PostRemoteDataSource {
  Future<Map<String, dynamic>> fetchPosts(int page, int limit);
  Future<Map<String, dynamic>> fetchUserSuggestions();
  Future<String?> uploadImage(File imageFile);
  Future<Map<String, dynamic>> createPost({
    required String content,
    required List<String> imageUrls,
  });
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

  @override
  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/upload/upload'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': _apiClient.headers['Authorization'] ?? '',
        'Accept': 'application/json',
      });

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var responseData = await streamedResponse.stream.bytesToString();
      
      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        var jsonResponse = json.decode(responseData);
        if (jsonResponse['success'] == true) {
          return jsonResponse['secure_url'];
        }
      }
      throw ServerException('Failed to upload image: ${responseData}');
    } catch (e) {
      throw ServerException('Failed to upload image: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createPost({
    required String content,
    required List<String> imageUrls,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.postsEndpoint,
        body: {
          'content': content,
          'images': imageUrls,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse;
        }
        throw ServerException('Failed to create post. Server returned success: false');
      }
      throw ServerException('Failed to create post. Status: ${response.statusCode}');
    } catch (e) {
      throw ServerException('Failed to create post: $e');
    }
  }
} 