import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/remote/post_remote_data_source.dart';
import '../models/post_model.dart';

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
} 