import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/firestore_service.dart';
import 'services/todo_ai_service.dart';
import 'services/session_service.dart';
import 'services/bmlt_service.dart';
import 'services/render_quality_service.dart';
import 'services/agent_mode_service.dart';
import 'config/env_config.dart';
import 'helpers/theme/app_theme.dart';
import 'route/routes.dart';
import 'route/routes_name.dart';
import 'helpers/services/navigation_service.dart';
import 'helpers/services/storage/local_storage.dart';
import 'helpers/theme/app_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration
  await EnvConfig.load();

  // Validate required environment variables
  final missingVars = EnvConfig.validate();
  if (missingVars.isNotEmpty) {
    throw Exception(
      'Missing required environment variables: ${missingVars.join(', ')}\n'
      'Please create a .env file based on .env.template and add your API keys.',
    );
  }

  // Print configuration summary in debug mode
  if (EnvConfig.enableDebugLogging) {
    EnvConfig.printSummary();
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize services
  await LocalStorage.init();

  // Initialize render quality service
  final renderQualityService = RenderQualityService();
  await renderQualityService.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthService()),
      ChangeNotifierProvider(create: (_) => ChatService()),
      ChangeNotifierProvider(create: (_) => FirestoreService()),
      ChangeNotifierProvider(create: (_) => BmltService()),
      ChangeNotifierProvider.value(value: renderQualityService),
      ChangeNotifierProvider(create: (context) =>
          TodoAIService(Provider.of<FirestoreService>(context, listen: false))),
      ChangeNotifierProvider(create: (context) =>
          SessionService(
            Provider.of<FirestoreService>(context, listen: false),
            Provider.of<TodoAIService>(context, listen: false),
          )),
      ChangeNotifierProvider(create: (_) => AgentModeService()..initialize()),
      ChangeNotifierProvider(create: (_) => AppNotifier()),
    ],
    child: MontaNAgentApp(renderQualityService: renderQualityService),
  ));
}

class MontaNAgentApp extends StatelessWidget {
  final RenderQualityService renderQualityService;

  const MontaNAgentApp({super.key, required this.renderQualityService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => BmltService()),
        ChangeNotifierProvider.value(value: renderQualityService),
        ChangeNotifierProvider(create: (context) =>
            TodoAIService(Provider.of<FirestoreService>(context, listen: false))),
        ChangeNotifierProvider(create: (context) =>
            SessionService(
              Provider.of<FirestoreService>(context, listen: false),
              Provider.of<TodoAIService>(context, listen: false),
            )),
        // Agent mode service for tool execution flows
        ChangeNotifierProvider(create: (_) => AgentModeService()..initialize()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        initialBinding: BindingsBuilder(() {
          // Register services with GetX
          Get.put<AuthService>(AuthService());
          Get.put<ChatService>(ChatService());
          Get.put<FirestoreService>(FirestoreService());
          Get.put<BmltService>(BmltService());
          Get.put<TodoAIService>(TodoAIService(Get.find<FirestoreService>()));
          Get.put<SessionService>(SessionService(
            Get.find<FirestoreService>(),
            Get.find<TodoAIService>(),
          ));
          Get.put<AgentModeService>(AgentModeService()..initialize());
        }),
        darkTheme: theme, // For now, use same theme for both
        themeMode: ThemeMode.light, // Default to light theme
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: RoutesName.dashboard,
        getPages: Routes.routes,
        builder: (context, child) {
          NavigationService.registerContext(context);
          return child ?? Container();
        },
      ),
    );
  }
}

