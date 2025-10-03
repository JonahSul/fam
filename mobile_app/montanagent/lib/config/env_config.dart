/// Environment Configuration
/// Provides secure access to environment variables
/// 
/// This class wraps flutter_dotenv to provide type-safe access to configuration
/// values with proper validation and error handling.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  /// Private constructor to prevent instantiation
  EnvConfig._();

  /// Load environment variables from .env file
  /// Should be called during app initialization
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // In production, .env file might not exist (using build-time config instead)
      // Log error but don't crash the app
      print('Warning: Could not load .env file: $e');
    }
  }

  /// Get a required environment variable
  /// Throws an exception if the variable is not set
  static String getRequired(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception(
        'Required environment variable $key is not set. '
        'Please check your .env file or build configuration.',
      );
    }
    return value;
  }

  /// Get an optional environment variable
  /// Returns the default value if the variable is not set
  static String getOptional(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Check if an environment variable is set
  static bool has(String key) {
    final value = dotenv.env[key];
    return value != null && value.isNotEmpty;
  }

  // Gemini API Configuration
  static String get geminiApiKey => getRequired('GEMINI_API_KEY');

  // Firebase Configuration (optional, as we use firebase_options.dart)
  static String? get firebaseProjectId => 
      has('FIREBASE_PROJECT_ID') ? dotenv.env['FIREBASE_PROJECT_ID'] : null;

  // Feature Flags
  static bool get enableAnalytics => 
      getOptional('ENABLE_ANALYTICS', defaultValue: 'true').toLowerCase() == 'true';

  static bool get enableDebugLogging => 
      getOptional('ENABLE_DEBUG_LOGGING', defaultValue: 'false').toLowerCase() == 'true';

  // API Configuration
  static String get apiTimeout => 
      getOptional('API_TIMEOUT_SECONDS', defaultValue: '30');

  /// Validate that all required environment variables are set
  /// Returns a list of missing required variables
  static List<String> validate() {
    final List<String> missing = [];
    
    // Check required variables
    final requiredVars = ['GEMINI_API_KEY'];
    
    for (final varName in requiredVars) {
      if (!has(varName)) {
        missing.add(varName);
      }
    }
    
    return missing;
  }

  /// Print configuration summary (for debugging)
  /// WARNING: Never log sensitive values in production!
  static void printSummary({bool includeSensitive = false}) {
    print('=== Environment Configuration ===');
    print('Gemini API Key: ${has('GEMINI_API_KEY') ? (includeSensitive ? geminiApiKey : '***') : 'NOT SET'}');
    print('Firebase Project ID: ${firebaseProjectId ?? 'Not configured in .env'}');
    print('Enable Analytics: $enableAnalytics');
    print('Enable Debug Logging: $enableDebugLogging');
    print('API Timeout: ${apiTimeout}s');
    print('================================');
  }
}
