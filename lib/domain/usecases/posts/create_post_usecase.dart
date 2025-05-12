import 'package:equatable/equatable.dart';
import '../base_usecase.dart';
import '../../repositories/post_repository.dart';

class CreatePostParams extends Equatable {
  final String content;
  final List<String> imageUrls;

  const CreatePostParams({
    required this.content,
    required this.imageUrls,
  });

  @override
  List<Object?> get props => [content, imageUrls];
}

class CreatePostUseCase implements UseCase<Map<String, dynamic>, CreatePostParams> {
  final PostRepository _postRepository;

  CreatePostUseCase(this._postRepository);

  @override
  Future<Map<String, dynamic>> call(CreatePostParams params) async {
    return await _postRepository.createPost(
      content: params.content,
      imageUrls: params.imageUrls,
    );
  }
} 