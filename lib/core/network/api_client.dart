import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final http.Client _client;
  String? _authToken;
  static const String _tokenKey = 'auth_token';

  ApiClient({http.Client? client}) : _client = client ?? http.Client() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  Map<String, String> get headers => {
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      };

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<http.Response> get(String endpoint) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }

  Future<http.Response> post(String endpoint,
      {required Map<String, dynamic> body}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }

  Future<http.Response> put(String endpoint,
      {required Map<String, dynamic> body}) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }

  Future<http.Response> changePassword(
      String endpoint,{
      required String currentPassword,
      required String newPassword,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
            body: json.encode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }
}
