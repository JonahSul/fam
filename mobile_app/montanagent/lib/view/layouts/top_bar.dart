import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/index.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: MySpacing.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumb or Page Title
          Expanded(
            child: Row(
              children: [
                MyText.titleMedium(
                  _getCurrentPageTitle(),
                  fontSize: 18,
                  fontWeight: 600,
                ),
              ],
            ),
          ),

          // Right side actions
          Row(
            children: [
              // Theme toggle button
              IconButton(
                onPressed: () {
                  // TODO: Implement theme toggle
                },
                icon: Icon(
                  Icons.dark_mode,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),

              MySpacing.width(8),

              // User avatar/menu
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor,
                child: MyText.bodySmall(
                  'U',
                  color: Colors.white,
                  fontWeight: 600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentPageTitle() {
    final currentRoute = Get.currentRoute;
    switch (currentRoute) {
      case '/dashboard':
        return 'Dashboard';
      case '/apps/chat':
        return 'Chat';
      case '/apps/todos':
        return 'Tasks';
      case '/apps/meetings':
        return 'Meetings';
      case '/apps/sessions':
        return 'Sessions';
      case '/auth/login':
        return 'Login';
      case '/auth/register':
        return 'Register';
      default:
        return 'MontaNAgent';
    }
  }
}
