import 'package:equatable/equatable.dart';
import 'package:friendzoneapp/domain/entities/user.dart';

class Story extends Equatable {
  final String id;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final int likeCount;
  final bool isHighlighted;
  final String? location;
  final String? filter;
  final String authorId;
  final String? highlightId;
  final User? author;
  final bool isLikedByCurrentUser;

  const Story({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiresAt,
    required this.viewCount,
    required this.likeCount,
    required this.isHighlighted,
    this.location,
    this.filter,
    required this.authorId,
    this.highlightId,
    this.author,
    this.isLikedByCurrentUser = false,
  });

  // --- ADD THIS copyWith METHOD ---
  Story copyWith({
    String? id,
    String? mediaUrl,
    String? mediaType,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    int? likeCount,
    bool? isHighlighted,
    String? location,
    String? filter,
    String? authorId,
    String? highlightId,
    User? author,
    bool? isLikedByCurrentUser,
  }) {
    return Story(
      id: id ?? this.id,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      location: location ?? this.location,
      filter: filter ?? this.filter,
      authorId: authorId ?? this.authorId,
      highlightId: highlightId ?? this.highlightId,
      author: author ?? this.author,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
  // --- END copyWith METHOD ---

  @override
  List<Object?> get props => [
    id,
    mediaUrl,
    mediaType,
    createdAt,
    expiresAt,
    viewCount,
    likeCount,
    isHighlighted,
    location,
    filter,
    authorId,
    highlightId,
    author,
    isLikedByCurrentUser,
  ];
}