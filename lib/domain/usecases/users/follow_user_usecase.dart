import 'package:friendzoneapp/domain/repositories/user_repository.dart';
import 'package:friendzoneapp/domain/usecases/base_usecase.dart';

class FollowUserParams {
  final String userId;
  const FollowUserParams(this.userId);
}

class FollowUserUseCase implements UseCase<void, FollowUserParams> {
  final UserRepository _userRepository;

  FollowUserUseCase(this._userRepository);

  @override
  Future<void> call(FollowUserParams params) async {
    await _userRepository.followUser(params.userId);
  }
} 