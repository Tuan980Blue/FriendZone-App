import 'package:equatable/equatable.dart';
import '../../entities/following_user.dart';
import '../../repositories/user_repository.dart';

class GetFollowingUsersUseCase {
  final UserRepository _userRepository;

  GetFollowingUsersUseCase(this._userRepository);

  Future<List<FollowingUser>> call() async {
    return await _userRepository.getFollowingUsers();
  }
} 