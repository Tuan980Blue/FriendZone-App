import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String username,
    required String fullName,
    String? avatar,
    String? bio,
    int postsCount = 0,
    int followersCount = 0,
    int followingCount = 0,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          email: email,
          username: username,
          fullName: fullName,
          avatar: avatar,
          bio: bio,
          postsCount: postsCount,
          followersCount: followersCount,
          followingCount: followingCount,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
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

      return UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        avatar: json['avatar']?.toString(),
        bio: json['bio']?.toString(),
        postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
        followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
        followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error parsing user model: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'avatar': avatar,
      'bio': bio,
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 