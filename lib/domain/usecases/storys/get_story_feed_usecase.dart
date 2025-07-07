import '../../entities/story.dart';
import '../../repositories/story_repository.dart';
import '../base_usecase.dart';

class GetStoryFeedUseCase implements UseCase<List<Story>, void> {
  final StoryRepository _storyRepository;

  GetStoryFeedUseCase(this._storyRepository);

  @override
  Future<List<Story>> call(void _) {
    return _storyRepository.getStoryFeed();
  }
}
