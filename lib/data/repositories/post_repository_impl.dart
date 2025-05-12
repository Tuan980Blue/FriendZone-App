import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/remote/post_remote_data_source.dart';
import '../models/post_model.dart';
import 'dart:io';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remoteDataSource;

  PostRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Post>> getPosts(int page, int limit) async {
    final response = await _remoteDataSource.fetchPosts(page, limit);
    final List<dynamic> postsJson = response['posts'];
    return postsJson.map((json) => PostModel.fromJson(json)).toList();
  }

  @override
  Future<List<dynamic>> getUserSuggestions() async {
    final response = await _remoteDataSource.fetchUserSuggestions();
    return response['suggestions'];
  }

  @override
  Future<String?> uploadImage(File imageFile) async {
    try {
      return await _remoteDataSource.uploadImage(imageFile);
    } catch (e) {
      print('Error in repository while uploading image: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createPost({
    required String content,
    required List<String> imageUrls,
  }) async {
    try {
      return await _remoteDataSource.createPost(
        content: content,
        imageUrls: imageUrls,
      );
    } catch (e) {
      print('Error in repository while creating post: $e');
      rethrow;
    }
  }
} 