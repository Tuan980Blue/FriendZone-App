import '../../entities/story.dart';
import '../../repositories/story_repository.dart';
import '../base_usecase.dart';

class GetMyStoriesUseCase implements UseCase<List<Story>, void> {
  final StoryRepository _storyRepository;

  GetMyStoriesUseCase(this._storyRepository);

  @override
  Future<List<Story>> call(void _) async {
    final stories = await _storyRepository.getMyStories();
    return stories;
  }
}
