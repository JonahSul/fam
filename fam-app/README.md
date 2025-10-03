# FAM App - React Native/Expo Mobile Application

A React Native mobile application built with Expo, featuring AI-powered chat through Firebase Genkit and Google's Gemini AI.

## Features

- 🔐 **Firebase Authentication**: Email/password and anonymous authentication
- 💬 **AI Chat**: Powered by Google Gemini through Firebase Genkit
- 💾 **Real-time Data**: Firestore for message persistence
- 🎨 **Modern UI**: Clean, intuitive interface with React Navigation
- 🔄 **Real-time Updates**: Live message synchronization
- 📱 **Cross-Platform**: Works on iOS, Android, and Web

## Quick Start

### Prerequisites

- Node.js 20.x or later
- npm or yarn
- Expo CLI: `npm install -g expo-cli`
- Firebase account
- Google AI API key (Gemini)

### Installation

```bash
# Clone the repository
cd fam-app

# Install dependencies
npm install

# Install functions dependencies
cd functions
npm install
cd ..

# Create environment configuration
cp .env.example .env
```

### Configuration

Edit `.env` with your Firebase configuration:

```env
EXPO_PUBLIC_FIREBASE_API_KEY=your_api_key
EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
EXPO_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
EXPO_PUBLIC_FIREBASE_APP_ID=your_app_id
```

### Firebase Setup

```bash
# Login to Firebase
firebase login

# Initialize Firebase (if not already done)
firebase init

# Deploy Firestore rules and indexes
firebase deploy --only firestore:rules,firestore:indexes

# Build and deploy Cloud Functions
cd functions
npm run build
cd ..
firebase deploy --only functions
```

### Running the App

```bash
# Start Expo development server
npm start

# Run on iOS simulator
npm run ios

# Run on Android emulator
npm run android

# Run on web
npm run web
```

## Project Structure

```
fam-app/
├── app/                      # Expo Router pages
│   ├── (auth)/              # Authentication screens
│   │   ├── login.tsx        # Login screen
│   │   └── register.tsx     # Registration screen
│   ├── (tabs)/              # Main app tabs
│   │   └── chat.tsx         # Chat screen
│   ├── _layout.tsx          # Root layout with auth routing
│   └── index.tsx            # Entry point
├── components/              # Reusable components
│   ├── chat/               # Chat-related components
│   │   ├── chat-input.tsx
│   │   ├── message-bubble.tsx
│   │   └── message-list.tsx
│   ├── error-boundary.tsx  # Error boundary component
│   ├── themed-text.tsx     # Themed text component
│   └── themed-view.tsx     # Themed view component
├── functions/              # Firebase Cloud Functions
│   └── src/
│       └── chat.ts         # Genkit chat flow
├── hooks/                  # Custom React hooks
│   ├── use-auth.ts        # Authentication hook
│   └── use-messages.ts    # Messages hook
├── firebase.ts            # Firebase configuration
├── firestore.rules        # Firestore security rules
├── firestore.indexes.json # Firestore indexes
└── package.json

```

## Key Components

### Authentication

The app uses Firebase Authentication with:
- Email/password registration and login
- Anonymous guest access
- Automatic route protection
- Persistent sessions

**Usage:**

```typescript
import { useAuth } from '@/hooks/use-auth';

function MyComponent() {
  const { user, loading } = useAuth();
  // user is null when not authenticated
}
```

### Chat Interface

Real-time chat with AI assistant:
- Message history stored in Firestore
- Real-time updates via Firestore listeners
- Streaming AI responses via Genkit
- Clean, modern UI with message bubbles

**Usage:**

```typescript
import { useMessages } from '@/hooks/use-messages';

function ChatComponent() {
  const { messages, loading, error } = useMessages();
  // messages array updates in real-time
}
```

### Firebase Cloud Functions

The `functions/` directory contains Genkit-powered Cloud Functions:

- `handleChatMessage`: Processes user messages and generates AI responses
- Automatically stores messages in Firestore
- Supports streaming responses

## Development

### Environment Variables

All configuration is managed through environment variables:

- **Required**: `EXPO_PUBLIC_FIREBASE_*` - Firebase configuration
- **Optional**: `EXPO_PUBLIC_USE_FIREBASE_EMULATOR` - Use local emulators

### Testing with Emulators

```bash
# Start Firebase emulators
firebase emulators:start

# In another terminal, start the app
EXPO_PUBLIC_USE_FIREBASE_EMULATOR=true npm start
```

### Error Handling

The app includes comprehensive error handling:

- Error boundaries catch React errors
- Network error handling in hooks
- User-friendly error messages
- Loading states for async operations

### Code Quality

```bash
# Type checking
npx tsc --noEmit

# Format code (if you add a formatter)
npm run format
```

## Building for Production

### Android

```bash
# Build APK
expo build:android

# Or using EAS Build
eas build --platform android
```

### iOS

```bash
# Build for iOS
expo build:ios

# Or using EAS Build
eas build --platform ios
```

### Web

```bash
# Build web version
expo build:web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## Deployment

See [DEPLOYMENT.md](../DEPLOYMENT.md) for comprehensive deployment instructions.

### Quick Deploy

```bash
# Deploy Cloud Functions
cd functions && npm run build && cd .. && firebase deploy --only functions

# Deploy Firestore rules
firebase deploy --only firestore:rules,firestore:indexes

# Deploy web app
expo build:web && firebase deploy --only hosting
```

## Security

### Firestore Rules

Security rules are defined in `firestore.rules`:

- Users can only read messages when authenticated
- Messages can only be created through Cloud Functions
- Proper validation and sanitization

### API Keys

- Never commit `.env` files
- Use GitHub Secrets for CI/CD
- Rotate keys regularly
- Use Firebase App Check in production

## Troubleshooting

### Common Issues

**Firebase not connecting:**
```bash
# Verify .env configuration
cat .env

# Check Firebase project
firebase projects:list
```

**Build errors:**
```bash
# Clear cache
expo start -c

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

**Functions not deploying:**
```bash
# Check Node version (must be 20)
node --version

# Rebuild functions
cd functions
rm -rf lib node_modules
npm install
npm run build
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

- Firebase: https://firebase.google.com/support
- Expo: https://docs.expo.dev/
- Genkit: https://firebase.google.com/docs/genkit

## License

See [LICENSE](../LICENSE) file for details.

---

**Fellowship Access Montana** - Connecting people with recovery resources
