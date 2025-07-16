import '../../repositories/post_repository.dart';

class DeletePostUseCase {
  final PostRepository _repository;
  DeletePostUseCase(this._repository);

  Future<Map<String, dynamic>> call({required String id}) async {
    return await _repository.deletePost(id: id);
  }
} 