import '../../repositories/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository _repository;
  UpdatePostUseCase(this._repository);

  Future<Map<String, dynamic>> call({required String id, required String content}) async {
    return await _repository.updatePost(id: id, content: content);
  }
} 