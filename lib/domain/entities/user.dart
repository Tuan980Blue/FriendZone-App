class User {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? avatar;
  final String? bio;
  final String? gender;
  final DateTime? birthDate;
  final String? status;
  final DateTime? lastSeen;
  final bool isPrivate;
  final String? website;
  final String? location;
  final String? phoneNumber;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.avatar,
    this.bio,
    this.gender,
    this.birthDate,
    this.status,
    this.lastSeen,
    this.isPrivate = false,
    this.website,
    this.location,
    this.phoneNumber,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.role = 'USER',
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
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

      return User(
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
      print('Error parsing user: $e');
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