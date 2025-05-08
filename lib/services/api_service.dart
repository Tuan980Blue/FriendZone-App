import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://web-socket-friendzone.onrender.com/api';
  static String? authToken;

  static Map<String, String> get _headers => {
    if (authToken != null) 'Authorization': 'Bearer $authToken',
    'Content-Type': 'application/json',
  };

  // Authentication methods
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        authToken = data['token'];
        return data;
      } else {
        final errorMessage = data['message'] ?? 'Failed to login';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error occurred. Please try again.');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
          'fullName': fullName,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        authToken = data['token'];
        return data;
      } else {
        final errorMessage = data['message'] ?? 'Failed to register';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error occurred. Please try again.');
    }
  }

  static Future<void> logout() async {
    authToken = null;
  }

  static Future<User> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return User.fromJson(data['user']);
      } else {
        final errorMessage = data['message'] ?? 'Failed to get user profile';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error occurred. Please try again.');
    }
  }

  // Existing methods
  static Future<Map<String, dynamic>> fetchPosts(int page, int limit) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?page=$page&limit=$limit'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchUserSuggestions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/follows/suggestions'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load suggestions: ${response.statusCode}');
    }
  }
} 