import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    return await _repository.register(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
    );
  }
} 