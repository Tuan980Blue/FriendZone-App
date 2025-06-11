class FollowingUser {
  final String id;
  final String username;
  final String fullName;
  final String? avatar;
  final String? bio;
  final String? status;
  final DateTime? lastSeen;
  final int followersCount;
  final bool isFollowing;

  const FollowingUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatar,
    this.bio,
    this.status,
    this.lastSeen,
    this.followersCount = 0,
    this.isFollowing = false,
  });

  factory FollowingUser.fromJson(Map<String, dynamic> json) {
    try {
      // Parse lastSeen date
      DateTime? lastSeen;
      try {
        lastSeen = json['lastSeen'] != null ? DateTime.parse(json['lastSeen'].toString()) : null;
      } catch (e) {
        lastSeen = null;
      }

      return FollowingUser(
        id: json['id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        avatar: json['avatar']?.toString(),
        bio: json['bio']?.toString(),
        status: json['status']?.toString(),
        lastSeen: lastSeen,
        followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
        isFollowing: json['isFollowing'] as bool? ?? false,
      );
    } catch (e) {
      print('Error parsing following user: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'avatar': avatar,
      'bio': bio,
      'status': status,
      'lastSeen': lastSeen?.toIso8601String(),
      'followersCount': followersCount,
      'isFollowing': isFollowing,
    };
  }
} 