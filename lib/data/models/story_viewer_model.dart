class StoryViewerModel {
  final String id;
  final String userId;
  final String storyId;
  final DateTime createdAt;
  final ViewerUser user;

  StoryViewerModel({
    required this.id,
    required this.userId,
    required this.storyId,
    required this.createdAt,
    required this.user,
  });

  factory StoryViewerModel.fromJson(Map<String, dynamic> json) {
    return StoryViewerModel(
      id: json['id'],
      userId: json['userId'],
      storyId: json['storyId'],
      createdAt: DateTime.parse(json['createdAt']),
      user: ViewerUser.fromJson(json['user']),
    );
  }
}

class ViewerUser {
  final String id;
  final String username;
  final String fullName;
  final String avatar;

  ViewerUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatar,
  });

  factory ViewerUser.fromJson(Map<String, dynamic> json) {
    return ViewerUser(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      avatar: json['avatar'],
    );
  }
}
