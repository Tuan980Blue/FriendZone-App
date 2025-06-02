import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String username,
    required String fullName,
    String? avatar,
    String? bio,
    String? gender,
    DateTime? birthDate,
    String? status,
    DateTime? lastSeen,
    bool isPrivate = false,
    String? website,
    String? location,
    String? phoneNumber,
    int postsCount = 0,
    int followersCount = 0,
    int followingCount = 0,
    bool isFollowing = false,
    String role = 'USER',
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          email: email,
          username: username,
          fullName: fullName,
          avatar: avatar,
          bio: bio,
          gender: gender,
          birthDate: birthDate,
          status: status,
          lastSeen: lastSeen,
          isPrivate: isPrivate,
          website: website,
          location: location,
          phoneNumber: phoneNumber,
          postsCount: postsCount,
          followersCount: followersCount,
          followingCount: followingCount,
          isFollowing: isFollowing,
          role: role,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse dates
      DateTime createdAt;
      DateTime updatedAt;
      DateTime? birthDate;
      DateTime? lastSeen;
      
      try {
        createdAt = DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String());
        updatedAt = DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String());
        birthDate = json['birthDate'] != null ? DateTime.parse(json['birthDate'].toString()) : null;
        lastSeen = json['lastSeen'] != null ? DateTime.parse(json['lastSeen'].toString()) : null;
      } catch (e) {
        createdAt = DateTime.now();
        updatedAt = DateTime.now();
        birthDate = null;
        lastSeen = null;
      }

      return UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        avatar: json['avatar']?.toString(),
        bio: json['bio']?.toString(),
        gender: json['gender']?.toString(),
        birthDate: birthDate,
        status: json['status']?.toString(),
        lastSeen: lastSeen,
        isPrivate: json['isPrivate'] as bool? ?? false,
        website: json['website']?.toString(),
        location: json['location']?.toString(),
        phoneNumber: json['phoneNumber']?.toString(),
        postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
        followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
        followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
        isFollowing: json['isFollowing'] as bool? ?? false,
        role: json['role']?.toString() ?? 'USER',
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
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'status': status,
      'lastSeen': lastSeen?.toIso8601String(),
      'isPrivate': isPrivate,
      'website': website,
      'location': location,
      'phoneNumber': phoneNumber,
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 