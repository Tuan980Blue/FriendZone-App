import '../entities/post.dart';
import 'dart:io';

abstract class PostRepository {
  Future<List<Post>> getPosts(int page, int limit);
  Future<List<dynamic>> getUserSuggestions();
  Future<String?> uploadImage(File imageFile);
  Future<Map<String, dynamic>> createPost({
    required String content,
    required List<String> imageUrls,
  });
  Future<Map<String, dynamic>> updatePost({
    required String id,
    required String content,
  });
  Future<Map<String, dynamic>> deletePost({
    required String id,
  });
} 