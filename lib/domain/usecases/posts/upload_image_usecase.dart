import 'dart:io';
import '../base_usecase.dart';
import '../../repositories/post_repository.dart';

class UploadImageUseCase implements UseCase<String?, File> {
  final PostRepository _postRepository;

  UploadImageUseCase(this._postRepository);

  @override
  Future<String?> call(File params) async {
    return await _postRepository.uploadImage(params);
  }
} 