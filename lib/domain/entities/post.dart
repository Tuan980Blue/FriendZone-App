import 'user.dart';

class Post {
  final String id;
  final String content;
  final List<String>? images;
  final String? location;
  final bool isArchived;
  final bool isHighlighted;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String>? tags;
  final String? filter;
  final String authorId;
  final User author;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.content,
    this.images,
    this.location,
    required this.isArchived,
    required this.isHighlighted,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    this.tags,
    this.filter,
    required this.authorId,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      // Parse author first to ensure it's valid
      final authorJson = json['author'] as Map<String, dynamic>? ?? {};
      final author = User.fromJson(authorJson);

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

      return Post(
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
} 