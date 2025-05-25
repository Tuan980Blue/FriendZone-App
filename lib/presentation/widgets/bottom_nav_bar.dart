import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final int? notificationCount;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              theme: theme,
            ),
            _buildNavItem(
              icon: Icons.search_outlined,
              selectedIcon: Icons.search_rounded,
              label: 'Discover',
              index: 1,
              theme: theme,
            ),
            _buildNavItem(
              icon: Icons.notifications_none_outlined,
              selectedIcon: Icons.notifications_rounded,
              label: 'Notifications',
              index: 2,
              theme: theme,
              badge: notificationCount,
            ),
            _buildNavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
              index: 3,
              theme: theme,
            ),
          ],
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
    int? badge,
  }) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => onDestinationSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected 
                      ? AppTheme.accentPink 
                      : theme.bottomNavigationBarTheme.unselectedItemColor,
                ),
                if (badge != null && badge > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink,
                        shape: BoxShape.circle,
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
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge > 99 ? '99+' : badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? AppTheme.accentPink 
                    : theme.bottomNavigationBarTheme.unselectedItemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 