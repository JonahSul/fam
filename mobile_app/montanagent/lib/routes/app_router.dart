import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/todo_list_screen.dart';
import '../screens/session_list_screen.dart';
import '../screens/meeting_search_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String chat = '/chat';
  static const String todos = '/todos';
  static const String sessions = '/sessions';
  static const String meetings = '/meetings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case todos:
        return MaterialPageRoute(builder: (_) => const TodoListScreen());
      case sessions:
        return MaterialPageRoute(builder: (_) => const SessionListScreen());
      case meetings:
        return MaterialPageRoute(builder: (_) => const MeetingSearchScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          return const ChatScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
