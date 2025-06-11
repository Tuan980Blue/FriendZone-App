import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:friendzoneapp/presentation/theme/app_theme.dart';
import '../blocs/following/following_bloc.dart';
import '../blocs/followers/followers_bloc.dart';
import '../../domain/entities/following_user.dart';
import '../../di/injection_container.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../../domain/usecases/users/follow_user_usecase.dart';
import '../../domain/usecases/users/unfollow_user_usecase.dart';
import 'profile_screen.dart';
import '../theme/app_page_transitions.dart';

class FollowingFollowersScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const FollowingFollowersScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<FollowingFollowersScreen> createState() => _FollowingFollowersScreenState();
}

class _FollowingFollowersScreenState extends State<FollowingFollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowingBloc>().add(LoadFollowingUsers());
      context.read<FollowersBloc>().add(LoadFollowersUsers());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Following & Followers',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: Column(
        children: [
          // Custom Tab Bar with counts
          _buildTabBarWithCounts(),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFollowingTab(),
                _buildFollowersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarWithCounts() {
    return BlocBuilder<FollowingBloc, FollowingState>(
      builder: (context, followingState) {
        int followingCount = 0;
        if (followingState is FollowingLoaded) {
          followingCount = followingState.users.length;
        }
        return BlocBuilder<FollowersBloc, FollowersState>(
          builder: (context, followersState) {
            int followersCount = 0;
            if (followersState is FollowersLoaded) {
              followersCount = followersState.users.length;
            }
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryBlue, // Màu gạch chân tab đang chọn
                indicatorWeight: 2,
                labelColor: AppTheme.primaryBlue, // Màu chữ tab đang chọn
                unselectedLabelColor: Colors.grey.shade600, // Màu chữ tab không chọn
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatCount(followingCount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('Following'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatCount(followersCount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('Followers'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    return BlocBuilder<FollowingBloc, FollowingState>(
      builder: (context, state) {
        if (state is FollowingLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        } else if (state is FollowingLoaded) {
          return _buildUsersList(state.users, 'following');
        } else if (state is FollowingError) {
          return _buildErrorState(
            'Error: ${state.message}',
            () => context.read<FollowingBloc>().add(LoadFollowingUsers()),
          );
        }
        return _buildEmptyState('following');
      },
    );
  }

  Widget _buildFollowersTab() {
    return BlocBuilder<FollowersBloc, FollowersState>(
      builder: (context, state) {
        if (state is FollowersLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        } else if (state is FollowersLoaded) {
          return _buildUsersList(state.users, 'followers');
        } else if (state is FollowersError) {
          return _buildErrorState(
            'Error: ${state.message}',
            () => context.read<FollowersBloc>().add(LoadFollowersUsers()),
          );
        }
        return _buildEmptyState('followers');
      },
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'following' ? Icons.person_add_outlined : Icons.people_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            type == 'following' 
                ? 'You\'re not following anyone yet'
                : 'No one is following you yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            type == 'following'
                ? 'When you follow people, you\'ll see their photos and videos here.'
                : 'When people follow you, you\'ll see them here.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<FollowingUser> users, String type) {
    if (users.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (type == 'following') {
          context.read<FollowingBloc>().add(RefreshFollowingUsers());
        } else {
          context.read<FollowersBloc>().add(RefreshFollowersUsers());
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: users.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade100,
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserTile(user, type);
        },
      ),
    );
  }

  Widget _buildUserTile(FollowingUser user, String type) {
    return InkWell(
      onTap: () => _navigateToUserProfile(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: user.avatar != null
                    ? CachedNetworkImage(
                        imageUrl: user.avatar!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Text(
                            user.fullName.isNotEmpty 
                                ? user.fullName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                      children: [
                        Text(
                          '${user.followersCount} followers',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (user.status == 'ONLINE')
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                      ]
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action Button
            _buildActionButton(user, type),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(FollowingUser user, String type) {
    if (type == 'following') {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => _handleMessageUser(user),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'Nhắn tin',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Followers tab
      if (user.isFollowing) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => _handleMessageUser(user),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  'Nhắn tin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade500,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => _handleFollowUser(user),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  'Theo dõi lại',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  void _handleMessageUser(FollowingUser user) {
    // TODO: Navigate to chat screen with this user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message ${user.fullName}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleFollowUser(FollowingUser user) {
    // TODO: Handle follow action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Followed ${user.fullName}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _navigateToUserProfile(FollowingUser user) {
    Navigator.push(
      context,
      AppPageTransitions.slideRight(
        ProfileScreen(
          getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
          logoutUseCase: sl<LogoutUseCase>(),
          getUserByIdUseCase: sl<GetUserByIdUseCase>(),
          updateProfileUseCase: sl<UpdateProfileUseCase>(),
          followUserUseCase: sl<FollowUserUseCase>(),
          unfollowUserUseCase: sl<UnfollowUserUseCase>(),
          userId: user.id,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
} 