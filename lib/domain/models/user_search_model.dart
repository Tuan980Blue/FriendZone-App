import 'package:equatable/equatable.dart';

class UserSearchModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String avatar;
  final String bio;
  final String status;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPrivate;
  final String? website;
  final String? location;
  final String? phoneNumber;
  final String gender;
  final DateTime? birthDate;
  final int followersCount;
  final int followingCount;
  final int postsCount;

  const UserSearchModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.avatar,
    required this.bio,
    required this.status,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
    required this.isPrivate,
    this.website,
    this.location,
    this.phoneNumber,
    required this.gender,
    this.birthDate,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatar: json['avatar'] as String,
      bio: json['bio'] as String,
      status: json['status'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPrivate: json['isPrivate'] as bool,
      website: json['website'] as String?,
      location: json['location'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as String,
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      followersCount: json['followersCount'] as int,
      followingCount: json['followingCount'] as int,
      postsCount: json['postsCount'] as int,
    );
  }

  @override
  List<Object?> get props => [
    id, username, email, fullName, avatar, bio, status,
    lastSeen, createdAt, updatedAt, isPrivate, website,
    location, phoneNumber, gender, birthDate,
    followersCount, followingCount, postsCount,
  ];
} 