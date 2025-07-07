import 'dart:io';
import '../../data/models/story_feed.dart';
import '../entities/story.dart';

abstract class StoryRepository {
  Future<List<Story>> getMyStories();
  Future<List<StoryFeedItem>> getStoryFeed();
  Future<String?> uploadMedia(File mediaFile);
  Future<Story> createStory({
    required String mediaUrl,
    required String mediaType,
    required String location,
    required String filter,
    required bool isHighlighted,
  });
}
