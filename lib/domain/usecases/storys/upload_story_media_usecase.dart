import 'dart:io';
import '../../repositories/story_repository.dart';
import '../base_usecase.dart';

class UploadStoryMediaUseCase implements UseCase<String?, File> {
  final StoryRepository _storyRepository;

  UploadStoryMediaUseCase(this._storyRepository);

  @override
  Future<String?> call(File params) {
    return _storyRepository.uploadMedia(params);
  }
}
