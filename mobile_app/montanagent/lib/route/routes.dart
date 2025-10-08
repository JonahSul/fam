import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../view/apps/chat_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../view/dashboard/dashboard_screen.dart';
import '../view/apps/placeholder_screen.dart';
import 'routes_name.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // For now, always allow access - we'll implement proper auth later
    return null;
  }
}

class Routes {
  static final List<GetPage> routes = [
    // Auth routes
    GetPage(name: RoutesName.login, page: () => const LoginScreen()),
    GetPage(name: RoutesName.register, page: () => const RegisterScreen()),
    
    // Main app routes with auth middleware
    GetPage(name: '/', page: () => const DashboardScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: RoutesName.dashboard, page: () => const DashboardScreen(), middlewares: [AuthMiddleware()]),
    GetPage(name: RoutesName.chat, page: () => const ChatScreen(), middlewares: [AuthMiddleware()]),
    
    // Placeholder routes for future features
    GetPage(name: RoutesName.todos, page: () => const PlaceholderScreen(title: 'Todos', description: 'Todo management coming soon'), middlewares: [AuthMiddleware()]),
    GetPage(name: RoutesName.meetings, page: () => const PlaceholderScreen(title: 'Meetings', description: 'Meeting management coming soon'), middlewares: [AuthMiddleware()]),
    GetPage(name: RoutesName.sessions, page: () => const PlaceholderScreen(title: 'Sessions', description: 'Session management coming soon'), middlewares: [AuthMiddleware()]),
  ];
}