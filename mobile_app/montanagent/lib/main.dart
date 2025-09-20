import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/gemini_service.dart';
import 'services/firestore_service.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MontaNAgentApp());
}

class MontaNAgentApp extends StatelessWidget {
  const MontaNAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GeminiService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
      ],
      child: Consumer<GeminiService>(
        builder: (context, geminiService, child) {
          // Initialize Gemini with API key (you'll need to set this)
          // In production, store this securely or get from environment
          if (!geminiService.isInitialized) {
            // TODO: Replace with your actual Gemini API key
            const geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
            if (geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
              geminiService.initialize(geminiApiKey);
            }
          }

          return MaterialApp(
            title: 'MontaNAgent',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            home: const AuthWrapper(),
            onGenerateRoute: AppRouter.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
