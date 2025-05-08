class Post {
  final String id;
  final String content;
  final List<String> images;
  final String createdAt;
  final String authorId;
  final Map<String, dynamic> author;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  Post({
    required this.id,
    required this.content,
    required this.images,
    required this.createdAt,
    required this.authorId,
    required this.author,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: json['createdAt'],
      authorId: json['authorId'],
      author: json['author'],
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
    );
  }
} 