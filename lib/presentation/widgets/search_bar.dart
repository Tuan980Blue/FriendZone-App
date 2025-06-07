import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friendzoneapp/domain/usecases/users/follow_user_usecase.dart';
import 'package:friendzoneapp/domain/usecases/users/unfollow_user_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../blocs/search/search_bloc.dart';
import '../blocs/search/search_event.dart';
import '../blocs/search/search_state.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/profile_screen.dart';

class CustomSearchBar extends StatefulWidget {
  final GetUserByIdUseCase getUserByIdUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final FollowUserUseCase followUserUseCase;
  final UnfollowUserUseCase unfollowUserUseCase;

  const CustomSearchBar({
    super.key,
    required this.getUserByIdUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.updateProfileUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontFamily: AppTheme.fontFamily,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context.read<SearchBloc>().add(SearchUsers(value));
                      setState(() => _isSearching = true);
                    } else {
                      context.read<SearchBloc>().add(ClearSearch());
                      setState(() => _isSearching = false);
                    }
                  },
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchBloc>().add(ClearSearch());
                    setState(() => _isSearching = false);
                  },
                ),
            ],
          ),
        ),
        if (_isSearching)
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchLoaded) {
                  if (state.users.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(user.avatar),
                          backgroundColor: AppTheme.backgroundLight,
                        ),
                        title: Text(
                          user.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.primaryBlue.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 14,
                                        color: AppTheme.primaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user.followersCount} followers',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryBlue,
                                          fontFamily: AppTheme.fontFamily,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.secondaryPurple.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 14,
                                        color: AppTheme.secondaryPurple,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user.followingCount} following',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.secondaryPurple,
                                          fontFamily: AppTheme.fontFamily,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          _focusNode.unfocus();
                          setState(() => _isSearching = false);
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                getCurrentUserUseCase: widget.getCurrentUserUseCase,
                                logoutUseCase: widget.logoutUseCase,
                                getUserByIdUseCase: widget.getUserByIdUseCase,
                                updateProfileUseCase: widget.updateProfileUseCase,
                                followUserUseCase: widget.followUserUseCase,
                                unfollowUserUseCase: widget.unfollowUserUseCase,
                                userId: user.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is SearchError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(
                        color: AppTheme.error,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
      ],
    );
  }
} 