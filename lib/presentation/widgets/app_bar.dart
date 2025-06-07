import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friendzoneapp/domain/usecases/users/follow_user_usecase.dart';
import 'package:friendzoneapp/domain/usecases/users/unfollow_user_usecase.dart';
import '../../di/injection_container.dart' as di;
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../theme/app_theme.dart';
import '../blocs/notification/notification_bloc.dart';
import '../blocs/search/search_bloc.dart';
import 'search_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(int)? onTabChanged;
  final int selectedIndex;

  const CustomAppBar({
    super.key,
    this.onTabChanged,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.cardLight,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo image
          Image.asset(
            'assets/images/logo04.png',
            height: 32,
            fit: BoxFit.contain,
          ),
          // Search and Action icons
          Row(
            children: [
              // Search icon that opens search overlay
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: BlocProvider(
                        create: (context) => di.sl<SearchBloc>(),
                        child: CustomSearchBar(
                          getUserByIdUseCase: di.sl<GetUserByIdUseCase>(),
                          getCurrentUserUseCase: di.sl<GetCurrentUserUseCase>(),
                          logoutUseCase: di.sl<LogoutUseCase>(),
                          updateProfileUseCase: di.sl<UpdateProfileUseCase>(),
                          followUserUseCase: di.sl<FollowUserUseCase>(),
                          unfollowUserUseCase: di.sl<UnfollowUserUseCase>(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              // Notification icon with badge
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  int unreadCount = 0;
                  if (state is NotificationLoaded) {
                    unreadCount = state.unreadCount;
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_none,
                            color: selectedIndex == 2
                                ? AppTheme.accentPink
                                : AppTheme.textPrimary,
                          ),
                          onPressed: () {
                            // Chuyển đến tab notifications (index 2)
                            onTabChanged?.call(2);
                            // Load unread count when navigating to notifications
                            context.read<NotificationBloc>().add(LoadUnreadCount());
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.cardLight,
                                  width: 1,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: AppTheme.accentPink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              // Message icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedIndex == 3 
                      ? AppTheme.accentPink.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: selectedIndex == 3 
                        ? AppTheme.accentPink
                        : AppTheme.textPrimary,
                  ),
                  onPressed: () {
                    // TODO: Implement message functionality
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 