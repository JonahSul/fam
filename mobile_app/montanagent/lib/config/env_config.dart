/// Environment Configuration
/// Provides secure access to environment variables
///
/// This class wraps flutter_dotenv to provide type-safe access to configuration
/// values with proper validation and error handling.

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  /// Private constructor to prevent instantiation
  EnvConfig._();

  /// Load environment variables from .env file
  /// Should be called during app initialization
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // In production, .env file might not exist (using build-time config instead)
      // Log error but don't crash the app
      debugPrint('Warning: Could not load .env file: $e');
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
      getOptional('ENABLE_ANALYTICS', defaultValue: 'true').toLowerCase() ==
      'true';

  static bool get enableDebugLogging =>
      getOptional('ENABLE_DEBUG_LOGGING', defaultValue: 'false')
          .toLowerCase() ==
      'true';

  // API Configuration
  static String get apiTimeout =>
      getOptional('API_TIMEOUT_SECONDS', defaultValue: '30');

  /// Validate that all required environment variables are set
  /// Returns a list of missing required variables
  static List<String> validate() {
    final missing = <String>[];

    // Check required variables
    const requiredVars = ['GEMINI_API_KEY'];

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
    debugPrint('=== Environment Configuration ===');
    debugPrint(
      'Gemini API Key: ${has('GEMINI_API_KEY') ? (includeSensitive ? geminiApiKey : '***') : 'NOT SET'}',
    );
    debugPrint(
      'Firebase Project ID: ${firebaseProjectId ?? 'Not configured in .env'}',
    );
    debugPrint('Enable Analytics: $enableAnalytics');
    debugPrint('Enable Debug Logging: $enableDebugLogging');
    debugPrint('API Timeout: ${apiTimeout}s');
    debugPrint('================================');
  }
}
