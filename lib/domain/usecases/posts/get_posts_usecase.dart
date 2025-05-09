import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository _repository;

  GetPostsUseCase(this._repository);

  Future<List<Post>> call(int page, int limit) async {
    return await _repository.getPosts(page, limit);
  }
} 