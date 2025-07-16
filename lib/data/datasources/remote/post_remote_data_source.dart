import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

abstract class PostRemoteDataSource {
  Future<Map<String, dynamic>> fetchPosts(int page, int limit);
  Future<Map<String, dynamic>> fetchUserSuggestions();
  Future<String?> uploadImage(File imageFile);
  Future<Map<String, dynamic>> createPost({
    required String content,
    required List<String> imageUrls,
  });
  // Thêm abstract method
  Future<Map<String, dynamic>> updatePost({
    required String id,
    required String content,
  });
  Future<Map<String, dynamic>> deletePost({
    required String id,
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
      // Check if file size exceeds 5MB and compress if needed
      final fileSize = await imageFile.length();
      final maxSize = 5 * 1024 * 1024; // 5MB in bytes
      
      File fileToUpload = imageFile;
      if (fileSize > maxSize) {
        fileToUpload = await _compressImage(imageFile);
        final compressedSize = await fileToUpload.length();
        
        if (compressedSize > maxSize) {
          // Try with lower quality
          final bytes = await fileToUpload.readAsBytes();
          final image = img.decodeImage(bytes);
          if (image != null) {
            final moreCompressedBytes = img.encodeJpg(image, quality: 60);
            final tempFile = File('${Directory.systemTemp.path}/more_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
            await tempFile.writeAsBytes(moreCompressedBytes);
            fileToUpload = tempFile;
          }
        }
      } else {
        print('🔍 [DEBUG] File size is within 5MB limit. No compression needed.');
      }
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/upload/upload'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': _apiClient.headers['Authorization'] ?? '',
        'Accept': 'application/json',
      });


      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          fileToUpload.path,
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
          print('🔍 [ERROR] Error message: ${jsonResponse['message'] ?? 'No error message'}');
        }
      } else {
        print('🔍 [ERROR] Upload failed - Status code: ${streamedResponse.statusCode}');
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

  // Thêm method updatePost
  @override
  Future<Map<String, dynamic>> updatePost({
    required String id,
    required String content,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.postsEndpoint}/$id',
        body: {
          'content': content,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse;
        }
        throw ServerException('Failed to update post. Server returned success: false');
      } else if (response.statusCode == 400 || response.statusCode == 403 || response.statusCode == 404) {
        final jsonResponse = json.decode(response.body);
        throw ServerException(jsonResponse['error'] ?? 'Failed to update post');
      }
      throw ServerException('Failed to update post. Status:  {response.statusCode}');
    } catch (e) {
      throw ServerException('Failed to update post: $e');
    }
  }

  // Thêm method deletePost
  @override
  Future<Map<String, dynamic>> deletePost({
    required String id,
  }) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.postsEndpoint}/$id',
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse;
        }
        throw ServerException('Failed to delete post. Server returned success: false');
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        final jsonResponse = json.decode(response.body);
        throw ServerException(jsonResponse['error'] ?? 'Failed to delete post');
      }
      throw ServerException('Failed to delete post. Status:  {response.statusCode}');
    } catch (e) {
      throw ServerException('Failed to delete post: $e');
    }
  }

  // Helper method to compress image
  Future<File> _compressImage(File imageFile) async {
    try {
      // Read the image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return imageFile;
      }
      
      // Calculate new dimensions while maintaining aspect ratio
      int maxWidth = 1920;
      int maxHeight = 1080;
      
      int newWidth = image.width;
      int newHeight = image.height;
      
      if (image.width > maxWidth || image.height > maxHeight) {
        if (image.width > image.height) {
          newWidth = maxWidth;
          newHeight = (image.height * maxWidth / image.width).round();
        } else {
          newHeight = maxHeight;
          newWidth = (image.width * maxHeight / image.height).round();
        }
      }

      // Resize the image
      final resizedImage = img.copyResize(image, width: newWidth, height: newHeight);
      
      // Compress with quality 85%
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

      // Create temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
      
    } catch (e) {
      print('🔍 [ERROR] Error compressing image: $e');
      return imageFile; // Return original file if compression fails
    }
  }
} 