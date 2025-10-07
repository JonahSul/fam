import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/index.dart';
import '../../../route/routes_name.dart';

class LeftBar extends StatelessWidget {
  const LeftBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Logo/Brand Area
          Container(
            padding: MySpacing.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.psychology,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
                MySpacing.height(12),
                MyText.titleMedium(
                  'MontaNAgent',
                  fontWeight: 600,
                  color: Theme.of(context).primaryColor,
                ),
                MyText.bodySmall(
                  'AI Recovery Companion',
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView(
              padding: MySpacing.symmetric(vertical: 16),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: RoutesName.dashboard,
                  isActive: Get.currentRoute == RoutesName.dashboard,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.chat,
                  title: 'Chat',
                  route: RoutesName.chat,
                  isActive: Get.currentRoute == RoutesName.chat,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.task,
                  title: 'Tasks',
                  route: RoutesName.todos,
                  isActive: Get.currentRoute == RoutesName.todos,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  title: 'Meetings',
                  route: RoutesName.meetings,
                  isActive: Get.currentRoute == RoutesName.meetings,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.archive,
                  title: 'Sessions',
                  route: RoutesName.sessions,
                  isActive: Get.currentRoute == RoutesName.sessions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      child: Container(
        margin: MySpacing.symmetric(horizontal: 16, vertical: 4),
        padding: MySpacing.all(12),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
            ),
            MySpacing.width(12),
            MyText.bodyMedium(
              title,
              color: isActive ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: isActive ? 600 : 400,
            ),
          ],
        ),
      ),
    );
  }
}
