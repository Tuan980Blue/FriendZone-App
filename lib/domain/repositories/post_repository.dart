import '../entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts(int page, int limit);
  Future<List<dynamic>> getUserSuggestions();
} 