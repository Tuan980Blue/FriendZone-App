import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../di/injection_container.dart';

class GoogleSignInUseCase {
  final String baseUrl = 'https://web-socket-friendzone.onrender.com/api';
  final ApiClient _apiClient;

  GoogleSignInUseCase() : _apiClient = sl<ApiClient>();

  Future<Map<String, dynamic>> call(Map<String, dynamic> googleUserInfo) async {
    try {
      // Transform Google user info to match backend expectations
      final Map<String, dynamic> requestBody = {
        'email': googleUserInfo['email'],
        'name': googleUserInfo['name'],
        'picture': googleUserInfo['picture'],
        'googleId': googleUserInfo['sub'] ?? googleUserInfo['googleId'],
      };
      if (googleUserInfo['password'] != null) {
        requestBody['password'] = googleUserInfo['password'];
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Lưu token vào ApiClient
        if (data['token'] != null) {
          await _apiClient.setAuthToken(data['token']);
        }
        return data;
      } else {
        throw Exception('Failed to login with Google: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during Google login: $e');
    }
  }
} 