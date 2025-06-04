import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final int? notificationCount;
  final VoidCallback? onCreatePost;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.notificationCount,
    this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32) / 5; // 32 = padding (16 * 2)

    return SafeArea(
      top: false,
      child: Container(
        height: 88, // Tăng chiều cao để đủ chỗ cho nút nổi
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none, // Cho phép tràn ra ngoài
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    theme: theme,
                    width: itemWidth,
                  ),
                  _buildNavItem(
                    icon: Icons.search_outlined,
                    selectedIcon: Icons.search_rounded,
                    label: 'Discover',
                    index: 1,
                    theme: theme,
                    width: itemWidth,
                  ),
                  SizedBox(width: itemWidth), // Spacer for create button
                  _buildNavItem(
                    icon: Icons.notifications_none_outlined,
                    selectedIcon: Icons.notifications_rounded,
                    label: 'Notifications',
                    index: 2,
                    theme: theme,
                    badge: notificationCount,
                    width: itemWidth,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 3,
                    theme: theme,
                    width: itemWidth,
                  ),
                ],
              ),
            ),
            // Create Post Button (centered)
            Positioned(
              top: -15,
              left: 0,
              right: 0,
              child: Center(
                child: _buildCreatePostButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostButton(BuildContext context) {
    return GestureDetector(
      onTap: onCreatePost,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentPink,
              AppTheme.accentPink.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPink.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required ThemeData theme,
    required double width,
    int? badge,
  }) {
    final isSelected = selectedIndex == index;
    
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => onDestinationSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.2 : 1.0,
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      size: 26,
                      color: isSelected 
                          ? AppTheme.accentPink
                          : Colors.black54,
                    ),
                  ),
                  if (badge != null && badge > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: _buildBadge(badge, theme),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? AppTheme.accentPink 
                      : Colors.black54,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int badge, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentPink,
            AppTheme.accentPink.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.bottomNavigationBarTheme.backgroundColor ?? Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPink.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Text(
        badge > 99 ? '99+' : badge.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
} 