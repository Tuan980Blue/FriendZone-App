import '../../../data/models/story_feed.dart';
import '../../repositories/story_repository.dart';
import '../base_usecase.dart';

class GetStoryFeedUseCase implements UseCase<List<StoryFeedItem>, void> {
  final StoryRepository _storyRepository;

  GetStoryFeedUseCase(this._storyRepository);

  @override
  Future<List<StoryFeedItem>> call(void _) {
    return _storyRepository.getStoryFeed();
  }
}