import 'package:equatable/equatable.dart';
import '../base_usecase.dart';
import '../../repositories/story_repository.dart';
import '../../entities/story.dart';

class CreateStoryParams extends Equatable {
  final String mediaUrl;
  final String mediaType;
  final String location;
  final String filter;
  final bool isHighlighted;

  const CreateStoryParams({
    required this.mediaUrl,
    required this.mediaType,
    required this.location,
    required this.filter,
    required this.isHighlighted,
  });

  @override
  List<Object?> get props => [mediaUrl, mediaType, location, filter];
}

class CreateStoryUseCase implements UseCase<Story, CreateStoryParams> {
  final StoryRepository _storyRepository;

  CreateStoryUseCase(this._storyRepository);

  @override
  Future<Story> call(CreateStoryParams params) async {
    return await _storyRepository.createStory(
      mediaUrl: params.mediaUrl,
      mediaType: params.mediaType,
      location: params.location,
      filter: params.filter,
      isHighlighted: params.isHighlighted,
    );
  }
}
