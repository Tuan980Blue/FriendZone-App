import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friendzoneapp/domain/entities/notification.dart';
import 'package:friendzoneapp/presentation/screens/post_detail_screen.dart';
import 'package:friendzoneapp/presentation/screens/profile_screen.dart';

import '../../di/injection_container.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../blocs/notification/notification_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
  final LogoutUseCase _logoutUseCase = sl<LogoutUseCase>();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  void _loadMoreNotifications() {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final currentState = context.read<NotificationBloc>().state;
      if (currentState is NotificationLoaded) {
        final currentPage = currentState.response.page;
        final totalPages = currentState.response.totalPages;
        if (currentPage < totalPages) {
          context.read<NotificationBloc>().add(
                LoadNotifications(
                  page: currentPage + 1,
                  limit: AppConstants.defaultPageSize,
                ),
              );
        }
      }
      setState(() => _isLoadingMore = false);
    }
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          getCurrentUserUseCase: _getCurrentUserUseCase,
          logoutUseCase: _logoutUseCase,
          getUserByIdUseCase: _getUserByIdUseCase,
          userId: userId,
        ),
      ),
    );
  }

  void _navigateToPostDetail(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.response.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    context.read<NotificationBloc>().add(MarkAllNotificationsAsRead());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    context.read<NotificationBloc>().add(const LoadNotifications());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationInitial || state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotificationLoaded) {
            final notifications = state.response.notifications;
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When you get notifications, they will appear here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications());
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: notifications.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == notifications.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final notification = notifications[index];
                  return NotificationItem(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context.read<NotificationBloc>().add(
                          MarkNotificationAsRead(notification.id),
                        );
                      }
                      if (notification.type == 'FOLLOW' && notification.followerId != null && notification.followerId!.isNotEmpty) {
                        _navigateToUserProfile(notification.followerId!);
                      } else if ((notification.type == 'LIKE' || notification.type == 'COMMENT') && notification.postId != null && notification.postId!.isNotEmpty) {
                        _navigateToPostDetail(notification.postId!);
                      }
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
} 