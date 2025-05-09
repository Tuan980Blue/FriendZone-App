import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get headers => {
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    'Content-Type': 'application/json',
  };

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<http.Response> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }

  Future<http.Response> post(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }

  Future<http.Response> put(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));
      return response;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }
} 