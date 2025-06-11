import '../../domain/entities/following_user.dart';

class FollowingUserModel extends FollowingUser {
  const FollowingUserModel({
    required String id,
    required String username,
    required String fullName,
    String? avatar,
    String? bio,
    String? status,
    DateTime? lastSeen,
    int followersCount = 0,
    bool isFollowing = false,
  }) : super(
          id: id,
          username: username,
          fullName: fullName,
          avatar: avatar,
          bio: bio,
          status: status,
          lastSeen: lastSeen,
          followersCount: followersCount,
          isFollowing: isFollowing,
        );

  factory FollowingUserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse lastSeen date
      DateTime? lastSeen;
      try {
        lastSeen = json['lastSeen'] != null ? DateTime.parse(json['lastSeen'].toString()) : null;
      } catch (e) {
        lastSeen = null;
      }

      return FollowingUserModel(
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
      print('Error parsing following user model: $e');
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