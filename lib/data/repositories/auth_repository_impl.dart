import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _remoteDataSource.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String birthDate,
  }) async {
    return await _remoteDataSource.register(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
      birthDate: birthDate,
    );
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  @override
  Future<User> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }
} 