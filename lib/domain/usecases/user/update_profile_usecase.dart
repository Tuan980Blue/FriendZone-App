import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call({
    required String id,
    required String username,
    required String email,
    required String fullName,
    String? avatar,
    String? bio,
    String? status,
    bool? isPrivate,
    String? website,
    String? location,
    String? phoneNumber,
    String? gender,
    DateTime? birthDate,
  }) async {
    try {
      return await repository.updateProfile(
        id: id,
        username: username,
        email: email,
        fullName: fullName,
        avatar: avatar,
        bio: bio,
        status: status,
        isPrivate: isPrivate,
        website: website,
        location: location,
        phoneNumber: phoneNumber,
        gender: gender,
        birthDate: birthDate,
      );
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
} 