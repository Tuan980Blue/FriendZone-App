import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/notification_response.dart';
import '../../../domain/usecases/notification/mark_notification_as_read_usecase.dart';
import '../../../domain/usecases/notification/mark_all_notifications_as_read_usecase.dart';
import '../../../domain/usecases/notification/get_unread_notifications_count_usecase.dart';
import '../../../domain/usecases/notifications/get_notifications_usecase.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final int page;
  final int limit;

  const LoadNotifications({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class LoadUnreadCount extends NotificationEvent {}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final NotificationResponse response;
  final int unreadCount;

  const NotificationLoaded({
    required this.response,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [response, unreadCount];

  NotificationLoaded copyWith({
    NotificationResponse? response,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      response: response ?? this.response,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllNotificationsAsReadUseCase;
  final GetUnreadNotificationsCountUseCase _getUnreadCountUseCase;

  NotificationBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
    required MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase,
    required GetUnreadNotificationsCountUseCase getUnreadCountUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markNotificationAsReadUseCase = markNotificationAsReadUseCase,
        _markAllNotificationsAsReadUseCase = markAllNotificationsAsReadUseCase,
        _getUnreadCountUseCase = getUnreadCountUseCase,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<LoadUnreadCount>(_onLoadUnreadCount);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (event.page == 1) {
        emit(NotificationLoading());
      }
      
      final response = await _getNotificationsUseCase(
        page: event.page,
        limit: event.limit,
      );
      
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        if (event.page == 1) {
          // If it's the first page, replace the notifications
          final unreadCount = await _getUnreadCountUseCase();
          emit(currentState.copyWith(
            response: response,
            unreadCount: unreadCount,
          ));
        } else {
          // If it's a subsequent page, append the notifications
          final updatedNotifications = [
            ...currentState.response.notifications,
            ...response.notifications,
          ];
          final updatedResponse = response.copyWith(
            notifications: updatedNotifications,
            total: response.total,
            page: response.page,
            limit: response.limit,
            totalPages: response.totalPages,
          );
          emit(currentState.copyWith(response: updatedResponse));
        }
      } else {
        final unreadCount = await _getUnreadCountUseCase();
        emit(NotificationLoaded(response: response, unreadCount: unreadCount));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _markNotificationAsReadUseCase(event.notificationId);
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.response.notifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        
        final updatedResponse = currentState.response.copyWith(
          notifications: updatedNotifications,
          total: currentState.response.total,
          page: currentState.response.page,
          limit: currentState.response.limit,
          totalPages: currentState.response.totalPages,
        );
        
        final unreadCount = await _getUnreadCountUseCase();
        emit(currentState.copyWith(
          response: updatedResponse,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _markAllNotificationsAsReadUseCase();
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.response.notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        
        final updatedResponse = currentState.response.copyWith(
          notifications: updatedNotifications,
          total: currentState.response.total,
          page: currentState.response.page,
          limit: currentState.response.limit,
          totalPages: currentState.response.totalPages,
        );
        
        final unreadCount = await _getUnreadCountUseCase();
        emit(currentState.copyWith(
          response: updatedResponse,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final unreadCount = await _getUnreadCountUseCase();
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(currentState.copyWith(unreadCount: unreadCount));
      } else {
        emit(NotificationLoaded(
          response: NotificationResponse(
            notifications: [],
            total: 0,
            page: 1,
            limit: 10,
            totalPages: 1,
          ),
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
} 