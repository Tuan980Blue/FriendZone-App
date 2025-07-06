import 'dart:io';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/remote/story_remote_data_source.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource _remoteDataSource;

  StoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Story>> getMyStories() async {
    final response = await _remoteDataSource.fetchMyStories();
    return response; // response đã là List<StoryModel> implements Story
  }

  @override
  Future<List<Story>> getStoryFeed() async {
    final response = await _remoteDataSource.fetchFeedStories();
    return response;
  }

  @override
  Future<String?> uploadMedia(File mediaFile) async {
    return await _remoteDataSource.uploadImage(mediaFile);
  }

  @override
  Future<Story> createStory({
    required String mediaUrl,
    required String mediaType,
    required String location,
    required String filter,
  }) async {
    return await _remoteDataSource.createStory(
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      location: location,
      filter: filter,
    );
  }
}
