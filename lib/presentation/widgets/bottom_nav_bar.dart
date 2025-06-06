import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final String? avatarUrl;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 12,
      color: Colors.white,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 0),
            _buildNavItem(Icons.person_add_rounded, 1),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(Icons.notifications, 2),
            _buildProfileNavItem(3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.pink.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.pink : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem(int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.pink.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[200],
          backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
              ? NetworkImage(avatarUrl!)
              : null,
          child: (avatarUrl == null || avatarUrl!.isEmpty)
              ? Icon(Icons.person, size: 22, color: isSelected ? Colors.pink : Colors.grey[500])
              : null,
        ),
      ),
    );
  }
}
