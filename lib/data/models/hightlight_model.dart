import 'story_model.dart';

class HighlightModel {
  final String id;
  final String name;
  final String coverImage;
  final String authorId;
  final List<StoryModel> stories;

  HighlightModel({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.authorId,
    required this.stories,
  });

  factory HighlightModel.fromJson(Map<String, dynamic> json) {
    return HighlightModel(
      id: json['id'],
      name: json['name'],
      coverImage: json['coverImage'],
      authorId: json['authorId'],
      stories: (json['stories'] as List<dynamic>)
          .map((e) => StoryModel.fromJson(e))
          .toList(),
    );
  }
}
