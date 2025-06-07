import 'package:friendzoneapp/domain/repositories/user_repository.dart';
import 'package:friendzoneapp/domain/usecases/base_usecase.dart';

class UnfollowUserParams {
  final String userId;
  const UnfollowUserParams(this.userId);
}

class UnfollowUserUseCase implements UseCase<void, UnfollowUserParams> {
  final UserRepository _userRepository;

  UnfollowUserUseCase(this._userRepository);

  @override
  Future<void> call(UnfollowUserParams params) async {
    await _userRepository.unfollowUser(params.userId);
  }
} 