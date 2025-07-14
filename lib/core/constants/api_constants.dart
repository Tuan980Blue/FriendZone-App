class ApiConstants {
  static const String baseUrl = 'https://web-socket-friendzone.onrender.com/api';
  static const int timeoutDuration = 10;

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/auth/me';
  static const String updateProfileEndpoint = '/auth/update';

  // Post endpoints
  static const String postsEndpoint = '/posts';
  static const String userSuggestionsEndpoint = '/follows/suggestions';
  
  // User endpoints
  static const String usersEndpoint = '/users';
  
  // Follow endpoints
  static const String followEndpoint = '/follows/follow';
  static const String unfollowEndpoint = '/follows/unfollow';
  static const String followingEndpoint = '/follows/following';
  static const String followersEndpoint = '/follows';
  
  // Chat endpoints
  static const String recentChatsEndpoint = '/chat/recent';
  static const String directChatMessagesEndpoint = '/chat/direct';

  //Story endpoints
  static const String storiesEndpoint = '/stories';
  static const String storyByIdEndpoint = '/stories/feed';
  static const String userStoriesEndpoint = '/stories/my/';
  static String likeStoryEndpoint(String storyId) => '/stories/$storyId/like';
  static const String createHighlightEndpoint = '/stories/highlights';
  static String deleteStoryEndpoint(String storyId) => '/stories/$storyId';
  static String deleteHightLightEndpoint(String storyId) => '/stories/highlights/$storyId';
} 