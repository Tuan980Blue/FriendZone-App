import '../../domain/entities/post.dart';
import 'user_model.dart';

class PostModel extends Post {
  const PostModel({
    required String id,
    required String content,
    List<String>? images,
    String? location,
    required bool isArchived,
    required bool isHighlighted,
    required int viewCount,
    required int likeCount,
    required int commentCount,
    required int shareCount,
    List<String>? tags,
    String? filter,
    required String authorId,
    required UserModel author,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          content: content,
          images: images,
          location: location,
          isArchived: isArchived,
          isHighlighted: isHighlighted,
          viewCount: viewCount,
          likeCount: likeCount,
          commentCount: commentCount,
          shareCount: shareCount,
          tags: tags,
          filter: filter,
          authorId: authorId,
          author: author,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse author first to ensure it's valid
      final authorJson = json['author'] as Map<String, dynamic>? ?? {};
      final author = UserModel.fromJson(authorJson);

      // Parse dates
      DateTime createdAt;
      DateTime updatedAt;
      try {
        createdAt = DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String());
        updatedAt = DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String());
      } catch (e) {
        createdAt = DateTime.now();
        updatedAt = DateTime.now();
      }

      // Parse lists
      List<String>? images;
      if (json['images'] != null) {
        try {
          images = (json['images'] as List).map((e) => e.toString()).toList();
        } catch (e) {
          images = null;
        }
      }

      List<String>? tags;
      if (json['tags'] != null) {
        try {
          tags = (json['tags'] as List).map((e) => e.toString()).toList();
        } catch (e) {
          tags = [];
        }
      }

      return PostModel(
        id: json['id']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        images: images,
        location: json['location']?.toString(),
        isArchived: json['isArchived'] as bool? ?? false,
        isHighlighted: json['isHighlighted'] as bool? ?? false,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
        shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
        tags: tags,
        filter: json['filter']?.toString(),
        authorId: json['authorId']?.toString() ?? '',
        author: author,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error parsing post: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'images': images,
      'location': location,
      'isArchived': isArchived,
      'isHighlighted': isHighlighted,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'tags': tags,
      'filter': filter,
      'authorId': authorId,
      'author': (author as UserModel).toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 