import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.backgroundDark : AppTheme.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode 
                ? Colors.grey.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                index: 0,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                label: 'Search',
                index: 1,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: Icons.add_box_outlined,
                selectedIcon: Icons.add_box,
                label: 'Post',
                index: 2,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: Icons.favorite_border_outlined,
                selectedIcon: Icons.favorite,
                label: 'Activity',
                index: 2,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
                index: 2,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isDarkMode,
  }) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => onDestinationSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected
                  ? isDarkMode ? AppTheme.darkModeAccent : AppTheme.accentPink
                  : isDarkMode ? AppTheme.darkModeText.withOpacity(0.7) : AppTheme.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? AppTheme.darkModeAccent : AppTheme.accentPink,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 