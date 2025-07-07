import 'dart:io';
import '../entities/story.dart';

abstract class StoryRepository {
  Future<List<Story>> getMyStories();
  Future<List<Story>> getStoryFeed();
  Future<String?> uploadMedia(File mediaFile);
  Future<Story> createStory({
    required String mediaUrl,
    required String mediaType,
    required String location,
    required String filter,
    required bool isHighlighted,
  });
}
