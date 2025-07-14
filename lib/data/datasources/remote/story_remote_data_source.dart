import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../models/hightlight_model.dart';
import '../../models/story_feed.dart';
import '../../models/story_model.dart';

abstract class StoryRemoteDataSource {
  Future<List<StoryFeedItem>> fetchFeedStoryGroups();
  Future<List<StoryModel>> fetchMyStories();
  Future<StoryModel> createStory({
    required String mediaUrl,
    required String mediaType,
    required String location,
    required String filter,
    required bool isHighlighted,
  });
  Future<String?> uploadImage(File imageFile);
  Future<void> likeStory(String storyId);
  Future<void> createHighlight({required String name, required List<String> storyIds});
  Future<List<HighlightModel>> fetchHighlights({required String userId});
  Future<void> deleteStory(String storyId);
  Future<void> deleteHighlight(String storyId);
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final ApiClient _apiClient;

  StoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<StoryFeedItem>> fetchFeedStoryGroups() async {
    final response = await _apiClient.get(ApiConstants.storyByIdEndpoint);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final items = data['data'] as List;
      return items.map((e) => StoryFeedItem.fromJson(e)).toList();
    } else {
      throw ServerException(data['message'] ?? 'Failed to fetch feed stories');
    }
  }

  @override
  Future<List<StoryModel>> fetchMyStories() async {
    final response = await _apiClient.get(ApiConstants.userStoriesEndpoint);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final stories = data['data'] as List;
      final parsed = stories.map((e) => StoryModel.fromJson(e)).toList();
      return parsed;
    } else {
      throw ServerException(data['message'] ?? 'Failed to fetch user stories');
    }
  }

  @override
  Future<StoryModel> createStory({
    required String mediaUrl,
    required String mediaType,
    required String location,
    required String filter,
    required bool isHighlighted,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.storiesEndpoint,
      body: {
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'location': location,
        'filter': filter,
        'isHighlighted': isHighlighted.toString(),
      },
    );

    final data = json.decode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
      return StoryModel.fromJson(data['data']);
    } else {
      throw ServerException(data['message'] ?? 'Failed to create story');
    }
  }

  @override
  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/upload/upload'),
      );

      request.headers.addAll({
        'Authorization': _apiClient.headers['Authorization'] ?? '',
        'Accept': 'application/json',
      });

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
        } else {
          throw ServerException(jsonResponse['message'] ?? 'Upload failed');
        }
      } else {
        throw ServerException('Upload failed with code ${streamedResponse.statusCode}');
      }
    } catch (e) {
      throw ServerException('Failed to upload story image: $e');
    }
  }

  @override
  Future<void> likeStory(String storyId) async {
    final response = await _apiClient.post(
      ApiConstants.likeStoryEndpoint(storyId),
      body: {},
    );

    final data = json.decode(response.body);
    debugPrint('Like story response: ${response.statusCode} - $data');

    if (response.statusCode == 200 && data['success'] == true) {
      debugPrint("Like thành công story $storyId");
    } else {
      throw ServerException(data['error'] ?? 'Like story thất bại');
    }
  }

  @override
  Future<void> createHighlight({
    required String name,
    required List<String> storyIds,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.createHighlightEndpoint,
      body: {
        'name': name,
        'storyIds': storyIds,
      },
    );

    final data = json.decode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
      debugPrint("✅ Tạo highlight thành công");
    } else {
      final errorMsg = data['error'] ?? data['message'] ?? 'Tạo highlight thất bại';
      throw ServerException(errorMsg);
    }
  }

  @override
  Future<List<HighlightModel>> fetchHighlights({required String userId}) async {
    final response = await _apiClient.get('/stories/highlights/$userId');
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final highlights = data['data'] as List;
      return highlights.map((e) => HighlightModel.fromJson(e)).toList();
    } else {
      throw ServerException(data['message'] ?? 'Failed to fetch highlights');
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    final response = await _apiClient.delete(ApiConstants.deleteStoryEndpoint(storyId));

    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = json.decode(response.body);
      throw ServerException(data['message'] ?? 'Xoá story thất bại');
    }

    debugPrint("✅ Đã xoá story $storyId");
  }

  @override
  Future<void> deleteHighlight(String storyId) async {
    final response = await _apiClient.delete(ApiConstants.deleteHightLightEndpoint(storyId));

    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = json.decode(response.body);
      throw ServerException(data['message'] ?? 'Xoá highlight thất bại');
    }

    debugPrint("✅ Đã xoá highlight $storyId");
  }

}