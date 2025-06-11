import 'package:equatable/equatable.dart';
import '../../entities/following_user.dart';
import '../../repositories/user_repository.dart';

class GetFollowersUsersUseCase {
  final UserRepository _userRepository;

  GetFollowersUsersUseCase(this._userRepository);

  Future<List<FollowingUser>> call() async {
    return await _userRepository.getFollowersUsers();
  }
} 