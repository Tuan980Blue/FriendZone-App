
import 'package:friendzoneapp/data/models/story_model.dart';
import 'package:friendzoneapp/data/models/user_model.dart';

class StoryFeedItem {
  final UserModel author;
  final List<StoryModel> stories;

  StoryFeedItem({
    required this.author,
    required this.stories,
  });

  factory StoryFeedItem.fromJson(Map<String, dynamic> json) {
    return StoryFeedItem(
      author: UserModel.fromJson(json['author']),
      stories: (json['stories'] as List)
          .map((s) => StoryModel.fromJson(s))
          .toList(),
    );
  }
}
