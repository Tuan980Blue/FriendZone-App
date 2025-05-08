class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? avatar;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.avatar,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      avatar: json['avatar'],
      bio: json['bio'],
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
    };
  }
} 