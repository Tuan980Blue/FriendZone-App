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
    String? location,
    String? filter,
    required String authorId,
    String? highlightId,
    UserModel? author,
    required bool isLikedByCurrentUser,
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
    isLikedByCurrentUser: isLikedByCurrentUser,
  );

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'];
    final author = authorJson != null
        ? UserModel.fromJson(authorJson)
        : null;

    return StoryModel(
      id: json['id'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'IMAGE',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ??
          DateTime.now().add(const Duration(hours: 24)),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      isHighlighted: json['isHighlighted'] ?? false,
      location: json['location'],
      filter: json['filter'],
      authorId: json['authorId'] ?? '',
      highlightId: json['highlightId'],
      author: author,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
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
      'author': author != null ? (author as UserModel).toJson() : null,
      'isLikedByCurrentUser': isLikedByCurrentUser,
    };
  }
}
