class ApiConstants {
  static const String baseUrl = 'https://web-socket-friendzone.onrender.com/api';
  static const int timeoutDuration = 10;

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/auth/me';

  // Post endpoints
  static const String postsEndpoint = '/posts';
  static const String userSuggestionsEndpoint = '/follows/suggestions';
  
  // Follow endpoints
  static const String followEndpoint = '/follows';
} 