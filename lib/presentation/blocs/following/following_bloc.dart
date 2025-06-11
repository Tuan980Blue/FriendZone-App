import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/following_user.dart';
import '../../../domain/usecases/users/get_following_users_usecase.dart';

// Events
abstract class FollowingEvent extends Equatable {
  const FollowingEvent();

  @override
  List<Object?> get props => [];
}

class LoadFollowingUsers extends FollowingEvent {}

class RefreshFollowingUsers extends FollowingEvent {}

// States
abstract class FollowingState extends Equatable {
  const FollowingState();

  @override
  List<Object?> get props => [];
}

class FollowingInitial extends FollowingState {}

class FollowingLoading extends FollowingState {}

class FollowingLoaded extends FollowingState {
  final List<FollowingUser> users;

  const FollowingLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class FollowingError extends FollowingState {
  final String message;

  const FollowingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FollowingBloc extends Bloc<FollowingEvent, FollowingState> {
  final GetFollowingUsersUseCase _getFollowingUsersUseCase;

  FollowingBloc({
    required GetFollowingUsersUseCase getFollowingUsersUseCase,
  })  : _getFollowingUsersUseCase = getFollowingUsersUseCase,
        super(FollowingInitial()) {
    on<LoadFollowingUsers>(_onLoadFollowingUsers);
    on<RefreshFollowingUsers>(_onRefreshFollowingUsers);
  }

  Future<void> _onLoadFollowingUsers(
    LoadFollowingUsers event,
    Emitter<FollowingState> emit,
  ) async {
    emit(FollowingLoading());
    try {
      final users = await _getFollowingUsersUseCase();
      emit(FollowingLoaded(users));
    } catch (e) {
      emit(FollowingError(e.toString()));
    }
  }

  Future<void> _onRefreshFollowingUsers(
    RefreshFollowingUsers event,
    Emitter<FollowingState> emit,
  ) async {
    emit(FollowingLoading());
    try {
      final users = await _getFollowingUsersUseCase();
      emit(FollowingLoaded(users));
    } catch (e) {
      emit(FollowingError(e.toString()));
    }
  }
} 