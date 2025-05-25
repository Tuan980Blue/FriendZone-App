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

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
  final LogoutUseCase _logoutUseCase = sl<LogoutUseCase>();
  bool _isLoadingMore = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NotificationBloc>().add(const LoadNotifications());
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.response.notifications.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.done_all,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    context.read<NotificationBloc>().add(MarkAllNotificationsAsRead());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Theme.of(context).colorScheme.onError,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading notifications...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            final notifications = state.response.notifications;
            if (notifications.isEmpty) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No notifications yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'When you get notifications, they will appear here',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications());
              },
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  itemCount: notifications.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == notifications.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
                        if (notification.type == 'FOLLOW' && 
                            notification.followerId != null && 
                            notification.followerId!.isNotEmpty) {
                          _navigateToUserProfile(notification.followerId!);
                        } else if ((notification.type == 'LIKE' || 
                                  notification.type == 'COMMENT') && 
                                  notification.postId != null && 
                                  notification.postId!.isNotEmpty) {
                          _navigateToPostDetail(notification.postId!);
                        }
                      },
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
} 