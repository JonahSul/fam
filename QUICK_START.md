# FAM Project - Quick Start Guide

Get all three components running locally in under 30 minutes.

## Prerequisites

Install these tools first:

```bash
# Node.js and npm
node --version  # Should be 20.x+
npm --version

# Firebase CLI
npm install -g firebase-tools

# Flutter (for MontaNAgent)
flutter --version  # Should be 3.22.0+

# Expo CLI (for FAM App)
npm install -g expo-cli
```

## Step 1: Clone and Setup (5 minutes)

```bash
# Clone the repository (if not already done)
cd /workspace

# Verify structure
ls -la
# Should see: fam-app/, mobile_app/, mcp-tool/
```

## Step 2: Get API Keys (10 minutes)

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing)
3. Enable these services:
   - Authentication (Email/Password + Anonymous)
   - Firestore Database
   - Cloud Functions
   - Hosting

4. Get your Firebase configuration:
   - Project Settings → General → Your apps
   - Copy the configuration values

### Google AI (Gemini) API

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create an API key
3. Save it securely

## Step 3: Configure Each Component (10 minutes)

### MCP Tool

```bash
cd mcp-tool

# Install dependencies
npm install

# Create .env
cat > .env << 'EOF'
BMLT_API_BASE=https://bmlt.mtrna.org/prod
SERVER_VERSION=0.0.1
LOG_LEVEL=debug
EOF

# Build
npm run build

# Test (Ctrl+C to exit)
node build/index.js
```

### FAM App

```bash
cd fam-app

# Install dependencies
npm install
cd functions && npm install && cd ..

# Create .env (replace with your values)
cat > .env << 'EOF'
EXPO_PUBLIC_FIREBASE_API_KEY=your_api_key_here
EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
EXPO_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
EXPO_PUBLIC_FIREBASE_APP_ID=your_app_id
EOF

# Initialize Firebase
firebase login
firebase use --add  # Select your project

# Deploy Firestore rules and functions
firebase deploy --only firestore:rules,firestore:indexes
cd functions && npm run build && cd ..
firebase deploy --only functions

# Start the app
npm start
```

### MontaNAgent

```bash
cd mobile_app/montanagent

# Install dependencies
flutter pub get

# Create .env (replace with your key)
cat > .env << 'EOF'
GEMINI_API_KEY=your_gemini_api_key_here
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGGING=true
API_TIMEOUT_SECONDS=30
EOF

# Run on web (easiest for testing)
flutter run -d chrome

# Or run on mobile
flutter run  # Will prompt for device
```

## Step 4: Verify Everything Works (5 minutes)

### MCP Tool
```bash
cd mcp-tool
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | node build/index.js
# Should list available tools
```

### FAM App
1. Open the Expo app (web or mobile)
2. Try registering a new account
3. Send a message in the chat
4. Verify the AI responds

### MontaNAgent
1. Open the Flutter app
2. Register or sign in
3. Send a message in the chat
4. Verify the AI responds

## Troubleshooting

### Common Issues

**Issue**: `npm install` fails
```bash
# Clear cache and retry
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

**Issue**: Firebase commands fail
```bash
# Re-login to Firebase
firebase logout
firebase login
```

**Issue**: Flutter build fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Issue**: Environment variables not loading
```bash
# Verify .env file exists
cat .env

# Ensure no extra spaces or quotes
# Should be: KEY=value (not KEY="value")
```

**Issue**: API keys don't work
- Double-check you copied them correctly
- Verify no extra spaces or newlines
- Check API key restrictions in Google Cloud Console
- Ensure billing is enabled for Gemini API

### Getting Help

1. Check the detailed README for each component
2. Review `DEPLOYMENT.md` for comprehensive setup
3. Check Firebase Console for error logs
4. Enable debug logging: `LOG_LEVEL=debug` or `ENABLE_DEBUG_LOGGING=true`

## Next Steps

After getting everything running locally:

1. **Review Security**: Check Firestore rules
2. **Set up Monitoring**: Enable Firebase Analytics
3. **Configure CI/CD**: Add GitHub Secrets
4. **Deploy to Production**: Follow `DEPLOYMENT.md`

## Quick Reference Commands

```bash
# MCP Tool
cd mcp-tool && npm run build && node build/index.js

# FAM App
cd fam-app && npm start

# FAM App Functions
cd fam-app/functions && npm run build && cd .. && firebase deploy --only functions

# MontaNAgent (Web)
cd mobile_app/montanagent && flutter run -d chrome

# MontaNAgent (Android)
cd mobile_app/montanagent && flutter run -d android

# MontaNAgent (iOS)
cd mobile_app/montanagent && flutter run -d ios
```

## Environment Variable Templates

### Complete .env for FAM App
```env
# Firebase Configuration
EXPO_PUBLIC_FIREBASE_API_KEY=AIza...
EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN=project-id.firebaseapp.com
EXPO_PUBLIC_FIREBASE_PROJECT_ID=project-id
EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET=project-id.appspot.com
EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
EXPO_PUBLIC_FIREBASE_APP_ID=1:123456789:web:abcdef

# Optional: Emulator
EXPO_PUBLIC_USE_FIREBASE_EMULATOR=false
```

### Complete .env for MontaNAgent
```env
# Required
GEMINI_API_KEY=AIza...

# Optional
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGGING=false
API_TIMEOUT_SECONDS=30
```

### Complete .env for MCP Tool
```env
BMLT_API_BASE=https://bmlt.mtrna.org/prod
SERVER_VERSION=0.0.1
USER_AGENT=fam/0.0.1
LOG_LEVEL=info
```

## Success Checklist

- [ ] All npm/flutter dependencies installed
- [ ] All .env files created and configured
- [ ] Firebase project created and configured
- [ ] API keys obtained (Firebase, Gemini)
- [ ] MCP Tool builds and runs
- [ ] FAM App starts without errors
- [ ] MontaNAgent builds and runs
- [ ] Can register and login in both apps
- [ ] AI chat works in both apps
- [ ] Firebase functions deploy successfully

---

**Total Time**: 30 minutes (assuming you have accounts and tools installed)

**Next**: Read `DEPLOYMENT.md` for production deployment instructions.
