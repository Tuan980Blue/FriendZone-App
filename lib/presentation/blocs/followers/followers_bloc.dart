import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/following_user.dart';
import '../../../domain/usecases/users/get_followers_users_usecase.dart';

// Events
abstract class FollowersEvent extends Equatable {
  const FollowersEvent();

  @override
  List<Object?> get props => [];
}

class LoadFollowersUsers extends FollowersEvent {}

class RefreshFollowersUsers extends FollowersEvent {}

// States
abstract class FollowersState extends Equatable {
  const FollowersState();

  @override
  List<Object?> get props => [];
}

class FollowersInitial extends FollowersState {}

class FollowersLoading extends FollowersState {}

class FollowersLoaded extends FollowersState {
  final List<FollowingUser> users;

  const FollowersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class FollowersError extends FollowersState {
  final String message;

  const FollowersError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FollowersBloc extends Bloc<FollowersEvent, FollowersState> {
  final GetFollowersUsersUseCase _getFollowersUsersUseCase;

  FollowersBloc({
    required GetFollowersUsersUseCase getFollowersUsersUseCase,
  })  : _getFollowersUsersUseCase = getFollowersUsersUseCase,
        super(FollowersInitial()) {
    on<LoadFollowersUsers>(_onLoadFollowersUsers);
    on<RefreshFollowersUsers>(_onRefreshFollowersUsers);
  }

  Future<void> _onLoadFollowersUsers(
    LoadFollowersUsers event,
    Emitter<FollowersState> emit,
  ) async {
    emit(FollowersLoading());
    try {
      final users = await _getFollowersUsersUseCase();
      emit(FollowersLoaded(users));
    } catch (e) {
      emit(FollowersError(e.toString()));
    }
  }

  Future<void> _onRefreshFollowersUsers(
    RefreshFollowersUsers event,
    Emitter<FollowersState> emit,
  ) async {
    emit(FollowersLoading());
    try {
      final users = await _getFollowersUsersUseCase();
      emit(FollowersLoaded(users));
    } catch (e) {
      emit(FollowersError(e.toString()));
    }
  }
} 