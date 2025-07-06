
import '../../domain/entities/story.dart';
import 'user_model.dart';

class StoryModel extends Story {
  const StoryModel({
    required String id,
    required String mediaUrl,
    required String mediaType,
    required DateTime createdAt,
    required DateTime expiresAt,
    required int viewCount,
    required int likeCount,
    required bool isHighlighted,
    required String location,
    required String filter,
    required String authorId,
    String? highlightId,
    required UserModel author,
  }) : super(
    id: id,
    mediaUrl: mediaUrl,
    mediaType: mediaType,
    createdAt: createdAt,
    expiresAt: expiresAt,
    viewCount: viewCount,
    likeCount: likeCount,
    isHighlighted: isHighlighted,
    location: location,
    filter: filter,
    authorId: authorId,
    highlightId: highlightId,
    author: author,
  );

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final author = UserModel.fromJson(json['author']);

    return StoryModel(
      id: json['id'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'IMAGE',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now().add(Duration(hours: 24)),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      isHighlighted: json['isHighlighted'] ?? false,
      location: json['location'] ?? '',
      filter: json['filter'] ?? '',
      authorId: json['authorId'] ?? '',
      highlightId: json['highlightId'],
      author: author,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isHighlighted': isHighlighted,
      'location': location,
      'filter': filter,
      'authorId': authorId,
      'highlightId': highlightId,
      'author': (author as UserModel).toJson(),
    };
  }
}
