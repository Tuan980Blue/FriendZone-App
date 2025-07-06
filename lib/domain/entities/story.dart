import 'package:equatable/equatable.dart';
import 'user.dart';

class Story extends Equatable {
  final String id;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final int likeCount;
  final bool isHighlighted;
  final String location;
  final String filter;
  final String authorId;
  final String? highlightId;
  final User author;

  const Story({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiresAt,
    required this.viewCount,
    required this.likeCount,
    required this.isHighlighted,
    required this.location,
    required this.filter,
    required this.authorId,
    required this.highlightId,
    required this.author,
  });

  @override
  List<Object?> get props => [id, mediaUrl, mediaType];
}
