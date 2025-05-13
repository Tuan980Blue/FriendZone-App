import '../entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String birthDate,
  });
  Future<void> logout();
  Future<User> getCurrentUser();
} 