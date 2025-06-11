import 'package:flutter/material.dart';
import 'package:friendzoneapp/presentation/theme/app_theme.dart';
import '../../screens/following_followers_screen.dart';
import '../../theme/app_page_transitions.dart';

class ProfileStats extends StatelessWidget {
  final int postsCount;
  final int followersCount;
  final int followingCount;

  const ProfileStats({
    super.key,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context, 
            'Posts', 
            postsCount, 
            null,
            icon: Icons.grid_on_outlined,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context, 
            'Followers', 
            followersCount, 
            () {
              Navigator.push(
                context,
                AppPageTransitions.slideUp(
                  const FollowingFollowersScreen(initialTabIndex: 1),
                ),
              );
            },
            icon: Icons.people_outline,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context, 
            'Following', 
            followingCount, 
            () {
              Navigator.push(
                context,
                AppPageTransitions.slideUp(
                  const FollowingFollowersScreen(initialTabIndex: 0),
                ),
              );
            },
            icon: Icons.person_add_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(0.5),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, 
    String label, 
    int count, 
    VoidCallback? onTap, {
    IconData? icon,
  }) {
    final isClickable = onTap != null;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Count
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isClickable 
                        ? AppTheme.primaryBlue
                        : AppTheme.primaryBlue,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
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