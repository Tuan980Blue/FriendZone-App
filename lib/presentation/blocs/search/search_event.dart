import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchUsers extends SearchEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {} 