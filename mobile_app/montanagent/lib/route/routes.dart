import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route/routes_name.dart';
import '../view/auth/login_screen.dart';
import '../view/auth/register_screen.dart';
import '../view/dashboard/dashboard_screen.dart';
import '../view/apps/chat_screen.dart';
import '../view/apps/placeholder_screen.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // For now, skip auth check - we can implement this later
    return null;
  }
}

List<GetPage> getPageRoute() => [
      GetPage(name: RoutesName.login, page: () => LoginScreen()),
      GetPage(name: RoutesName.register, page: () => RegisterScreen()),
      GetPage(name: RoutesName.dashboard, page: () => DashboardScreen()),
      GetPage(name: RoutesName.chat, page: () => ChatScreen()),
      GetPage(name: RoutesName.todos, page: () => PlaceholderScreen(
        title: 'Tasks',
        description: 'Task management features will be available soon. For now, use the chat to create and manage your recovery tasks.',
      )),
      GetPage(name: RoutesName.meetings, page: () => PlaceholderScreen(
        title: 'Meetings',
        description: 'Meeting finder and scheduling features will be available soon. Use the chat to find local NA meetings.',
      )),
      GetPage(name: RoutesName.sessions, page: () => PlaceholderScreen(
        title: 'Sessions',
        description: 'Session history and management features will be available soon.',
      )),
    ];

GetPage _authMiddleware(String name, Widget Function() page) => GetPage(
    name: name,
    page: page,
    middlewares: [AuthMiddleware()],
    transition: Transition.noTransition);
