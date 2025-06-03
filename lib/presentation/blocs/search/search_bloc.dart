import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/models/user_search_model.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiClient _apiClient;

  SearchBloc({required ApiClient apiClient}) 
      : _apiClient = apiClient,
        super(SearchInitial()) {
    on<SearchUsers>(_onSearchUsers);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    final searchEndpoint = '/users/search?q=${event.query}';
    emit(SearchLoading());

    try {
      final response = await _apiClient.get(searchEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final users = jsonList.map((json) => UserSearchModel.fromJson(json)).toList();
        emit(SearchLoaded(users));
      } else {
        emit(SearchError('Failed to search users. Status code: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SearchError('Error searching users: ${e.toString()}'));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
} 