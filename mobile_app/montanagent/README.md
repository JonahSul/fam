# montanagent

# MontaNAgent - AI Recovery Companion

MontaNAgent is a Flutter application that provides an AI-powered chat interface for Fellowship Access Montana, helping users with recovery support and meeting information through Google's Gemini AI.

## Features

- 🤖 **AI Chat Interface**: Powered by Google Gemini AI
- 🔐 **Firebase Authentication**: Secure user login and registration
- 💾 **Cloud Storage**: Chat history stored in Firestore
- 📱 **Cross-Platform**: Runs on iOS, Android, and Web
- 🎨 **Modern UI**: Clean, intuitive interface with Material Design 3
- 👤 **Anonymous Access**: Guest users can chat without registration

## Prerequisites

- Flutter SDK (3.22 or later)
- Firebase project with the following services enabled:
  - Authentication (Email/Password and Anonymous)
  - Firestore Database
  - Hosting (for web deployment)
- Google AI API key for Gemini

## Setup Instructions

### 1. Clone and Setup Flutter

```bash
git clone <your-repo-url>
cd mobile_app/montanagent
flutter pub get
```

### 2. Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication with Email/Password and Anonymous sign-in
3. Enable Firestore Database
4. Enable Hosting (for web deployment)

#### Using FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

#### Manual Configuration
If FlutterFire CLI doesn't work, manually update `lib/firebase_options.dart` with your Firebase project configuration.

### 3. Gemini AI Setup

1. Get a Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Update `lib/main.dart` and replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key

**⚠️ Security Note**: In production, store the API key securely using environment variables or Firebase Remote Config.

### 4. Firestore Security Rules

Deploy the included Firestore rules:
```bash
firebase deploy --only firestore:rules
```

## Running the App

### Development
```bash
# Run on connected device/emulator
flutter run

# Run on web (Chrome)
flutter run -d chrome

# Run on specific platform
flutter run -d ios
flutter run -d android
```

### Building for Production

#### Web
```bash
flutter build web --release
```

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Deployment

### Firebase Hosting (Web)

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Deploy using the provided script:
```bash
./deploy.sh
```

Or manually:
```bash
flutter build web --release
firebase deploy --only hosting
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── routes/
│   └── app_router.dart      # Navigation routing
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── chat_screen.dart     # Main chat interface
└── services/
    ├── auth_service.dart    # Firebase Authentication
    ├── gemini_service.dart  # Google AI Gemini integration
    └── firestore_service.dart # Firestore database operations
```

## Key Features Implementation

### Authentication
- Email/password registration and login
- Anonymous guest access
- Secure user session management
- Password reset functionality

### AI Chat
- Real-time chat with Gemini AI
- Context-aware responses
- Recovery-focused system prompts
- Message history persistence

### Data Storage
- User-specific chat history in Firestore
- Secure data access rules
- Offline capability (when available)

## Environment Variables

For production deployment, consider using these environment variables:

- `GEMINI_API_KEY`: Your Google AI Gemini API key
- `FIREBASE_PROJECT_ID`: Your Firebase project ID

## Troubleshooting

### Common Issues

1. **Build errors**: Run `flutter clean && flutter pub get`
2. **Firebase connection issues**: Verify `firebase_options.dart` configuration
3. **Gemini API errors**: Check API key validity and billing setup
4. **Platform-specific issues**: Ensure platform-specific setup is complete

### Platform Setup

#### iOS
- Minimum iOS version: 12.0
- Ensure iOS deployment target is set correctly in `ios/Runner.xcodeproj`

#### Android
- Minimum SDK version: 21
- Ensure `android/app/build.gradle` has correct configurations

#### Web
- Ensure web support is enabled: `flutter config --enable-web`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of Fellowship Access Montana and follows the project's licensing terms.

## Support

For issues related to:
- **App functionality**: Open an issue in this repository
- **Firebase setup**: Check [Firebase documentation](https://firebase.google.com/docs)
- **Flutter development**: See [Flutter documentation](https://flutter.dev/docs)
- **Gemini AI**: Reference [Google AI documentation](https://ai.google.dev/)

---

**MontaNAgent** - Empowering recovery through technology 🌟

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
