import '../../repositories/user_repository.dart';

class GetUserSuggestionsUseCase {
  final UserRepository _repository;

  GetUserSuggestionsUseCase(this._repository);

  Future<List<dynamic>> call() async {
    return await _repository.getUserSuggestions();
  }
} 