# FAM Project - Production Deployment Guide

This guide provides comprehensive instructions for deploying all components of the Fellowship Access Montana (FAM) project to production.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Component 1: MCP Tool](#component-1-mcp-tool)
4. [Component 2: FAM App (React Native/Expo)](#component-2-fam-app-react-nativeexpo)
5. [Component 3: MontaNAgent (Flutter)](#component-3-montanagent-flutter)
6. [Security Best Practices](#security-best-practices)
7. [Monitoring and Maintenance](#monitoring-and-maintenance)
8. [Troubleshooting](#troubleshooting)

## Overview

The FAM project consists of three main components:

1. **MCP Tool**: A Model Context Protocol server for BMLT API integration
2. **FAM App**: A React Native/Expo mobile app with Firebase and AI chat
3. **MontaNAgent**: A Flutter cross-platform app with AI capabilities

## Prerequisites

### Required Tools

- Node.js 20.x or later
- npm or yarn
- Git
- Firebase CLI: `npm install -g firebase-tools`
- Flutter SDK 3.22.0 or later (for MontaNAgent)
- Expo CLI (for FAM App)

### Required Accounts & Credentials

- Firebase account with billing enabled
- Google Cloud account (for Gemini AI API)
- GitHub account (for CI/CD)
- Apple Developer account (for iOS deployment)
- Google Play Console account (for Android deployment)

### API Keys Required

1. **Gemini API Key**: Get from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. **Firebase Configuration**: Get from Firebase Console
3. **BMLT API**: (public, no key required)

## Component 1: MCP Tool

### Local Setup

```bash
cd mcp-tool

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env with your configuration
nano .env

# Build the project
npm run build

# Test locally
node build/index.js
```

### Environment Variables

Create `.env` file:

```env
BMLT_API_BASE=https://bmlt.mtrna.org/prod
SERVER_VERSION=0.0.1
USER_AGENT=fam/0.0.1
LOG_LEVEL=info
```

### Production Deployment

#### Option 1: Docker

```bash
cd mcp-tool

# Build Docker image
docker build -t fam-mcp:latest .

# Run container
docker run -i \
  -e BMLT_API_BASE=https://bmlt.mtrna.org/prod \
  -e LOG_LEVEL=info \
  fam-mcp:latest
```

#### Option 2: systemd Service

Create `/etc/systemd/system/fam-mcp.service`:

```ini
[Unit]
Description=FAM MCP Server
After=network.target

[Service]
Type=simple
User=fam
WorkingDirectory=/opt/fam-mcp
Environment="NODE_ENV=production"
Environment="LOG_LEVEL=info"
ExecStart=/usr/bin/node /opt/fam-mcp/build/index.js
Restart=on-failure
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable fam-mcp
sudo systemctl start fam-mcp
sudo systemctl status fam-mcp
```

### CI/CD

GitHub Actions workflow is configured in `.github/workflows/mcp-tool-ci.yml`.

**Required Secrets:**
- (None required for basic build)

## Component 2: FAM App (React Native/Expo)

### Local Setup

```bash
cd fam-app

# Install dependencies
npm install

# Install functions dependencies
cd functions
npm install
cd ..

# Create .env file
cp .env.example .env

# Edit with your Firebase configuration
nano .env
```

### Firebase Setup

1. **Initialize Firebase Project**

```bash
firebase login
firebase init
```

Select:
- Functions (Cloud Functions)
- Firestore
- Hosting

2. **Configure Firestore Security Rules**

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

3. **Deploy Cloud Functions**

```bash
cd functions
npm run build
cd ..
firebase deploy --only functions
```

### Environment Variables

Create `.env` file in `fam-app/`:

```env
# Firebase Configuration
EXPO_PUBLIC_FIREBASE_API_KEY=your_api_key
EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
EXPO_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
EXPO_PUBLIC_FIREBASE_APP_ID=your_app_id

# Genkit/AI Configuration
EXPO_PUBLIC_GENKIT_API_KEY=your_genkit_api_key
```

### Production Deployment

#### Build for iOS

```bash
# Build iOS app
expo build:ios

# Or using EAS Build
eas build --platform ios
```

Upload to App Store using Xcode or `eas submit`.

#### Build for Android

```bash
# Build Android APK
expo build:android

# Or using EAS Build
eas build --platform android

# Submit to Play Store
eas submit --platform android
```

#### Deploy Web App

```bash
# Build web version
expo build:web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### CI/CD

GitHub Actions workflow is configured in `.github/workflows/fam-app-ci.yml`.

**Required Secrets:**
- `FIREBASE_TOKEN`: Run `firebase login:ci` to generate
- `FIREBASE_PROJECT_ID`: Your Firebase project ID
- Firebase service account JSON (for hosting deploy)

## Component 3: MontaNAgent (Flutter)

### Local Setup

```bash
cd mobile_app/montanagent

# Get dependencies
flutter pub get

# Create .env file
cp .env.template .env

# Edit with your API keys
nano .env
```

### Environment Variables

Create `.env` file:

```env
GEMINI_API_KEY=your_gemini_api_key_here
ENABLE_ANALYTICS=true
ENABLE_DEBUG_LOGGING=false
API_TIMEOUT_SECONDS=30
```

### Production Deployment

#### Build for Android

```bash
cd mobile_app/montanagent

# Build release APK
flutter build apk --release

# Or build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

Upload to Google Play Console.

#### Build for iOS

```bash
cd mobile_app/montanagent

# Build for iOS
flutter build ios --release

# Open in Xcode for signing and upload
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device" as target
2. Product → Archive
3. Distribute App → App Store Connect

#### Build for Web

```bash
cd mobile_app/montanagent

# Build web app
flutter build web --release

# Deploy to Firebase Hosting
cd ../..
firebase deploy --only hosting
```

### Using Makefile Commands

```bash
# Install dependencies
make install

# Run tests and analysis
make test
make analyze

# Build for specific platforms
make build-android
make build-ios
make build-web

# Deploy web app
make deploy-web
```

### CI/CD

GitHub Actions workflow is configured in `.github/workflows/montanagent-ci.yml`.

**Required Secrets:**
- `GEMINI_API_KEY`: Your Google AI Gemini API key
- `FIREBASE_SERVICE_ACCOUNT`: Firebase service account JSON
- `FIREBASE_PROJECT_ID`: Your Firebase project ID

## Security Best Practices

### 1. API Keys Management

**DO:**
- ✅ Use environment variables for all API keys
- ✅ Add `.env` to `.gitignore`
- ✅ Use Firebase Remote Config for mobile apps
- ✅ Rotate API keys regularly
- ✅ Use GitHub Secrets for CI/CD

**DON'T:**
- ❌ Commit API keys to version control
- ❌ Hardcode secrets in source code
- ❌ Share `.env` files publicly
- ❌ Use the same keys for dev and prod

### 2. Firebase Security Rules

Always review and test Firestore security rules:

```bash
# Test rules locally
firebase emulators:start --only firestore

# Deploy rules
firebase deploy --only firestore:rules
```

### 3. HTTPS Only

Ensure all production deployments use HTTPS:
- Firebase Hosting automatically provides HTTPS
- Configure SSL certificates for custom domains

### 4. Authentication

- Enable App Check for Firebase (prevents API abuse)
- Implement rate limiting in Cloud Functions
- Use Firebase Authentication for user management

## Monitoring and Maintenance

### Logging

**MCP Tool:**
```bash
# View logs (systemd)
journalctl -u fam-mcp -f

# View logs (Docker)
docker logs -f <container_id>
```

**Firebase:**
```bash
# View function logs
firebase functions:log

# Real-time logs
firebase functions:log --follow
```

### Performance Monitoring

1. **Firebase Performance Monitoring**: Enable in Firebase Console
2. **Error Reporting**: Use Firebase Crashlytics for mobile apps
3. **Analytics**: Enable Firebase Analytics

### Regular Maintenance

- **Weekly**: Review error logs and analytics
- **Monthly**: Update dependencies (`npm update`, `flutter pub upgrade`)
- **Quarterly**: Rotate API keys and review security rules
- **As needed**: Monitor API usage and costs

## Troubleshooting

### Common Issues

#### MCP Tool

**Issue**: Server won't start
```bash
# Check configuration
cat .env

# Test with debug logging
LOG_LEVEL=debug node build/index.js
```

**Issue**: BMLT API not responding
```bash
# Test API directly
curl "https://bmlt.mtrna.org/prod/client_interface/jsonp/?switcher=GetSearchResults&limit=1"
```

#### FAM App

**Issue**: Firebase connection failed
```bash
# Verify Firebase config
cat .env

# Test with Firebase emulator
firebase emulators:start
```

**Issue**: Build fails
```bash
# Clear cache
expo start -c

# Reinstall dependencies
rm -rf node_modules
npm install
```

#### MontaNAgent

**Issue**: Build fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build <platform>
```

**Issue**: API key not loading
```bash
# Verify .env file exists and is loaded
cat .env

# Check flutter logs
flutter run --verbose
```

### Getting Help

- Check component-specific README files
- Review GitHub Issues
- Firebase Support: https://firebase.google.com/support
- Flutter Support: https://flutter.dev/community

## Cost Optimization

### Firebase

- Set up budget alerts in Google Cloud Console
- Use Firestore query limits
- Implement caching to reduce function invocations
- Monitor API usage in Firebase Console

### Gemini AI

- Set rate limits in Cloud Functions
- Cache common responses
- Monitor API usage in Google Cloud Console
- Consider using smaller models for simple queries

### Hosting

- Enable CDN caching
- Compress assets
- Use appropriate image formats
- Implement lazy loading

## Rollback Procedures

### Cloud Functions

```bash
# List recent deployments
firebase functions:log

# Rollback to previous version
firebase deploy --only functions --force
```

### Hosting

```bash
# View deployment history
firebase hosting:history

# Rollback to specific version
firebase hosting:rollback <version_id>
```

### Mobile Apps

- Keep previous APK/IPA builds
- Use staged rollouts in app stores
- Implement feature flags for major changes

---

## Quick Reference

### Essential Commands

```bash
# MCP Tool
cd mcp-tool && npm run build && node build/index.js

# FAM App Functions
cd fam-app/functions && npm run build && cd .. && firebase deploy --only functions

# MontaNAgent Android
cd mobile_app/montanagent && flutter build apk --release

# MontaNAgent iOS
cd mobile_app/montanagent && flutter build ios --release

# MontaNAgent Web
cd mobile_app/montanagent && flutter build web --release && firebase deploy --only hosting
```

### Production Checklist

Before deploying to production:

- [ ] All API keys configured in environment variables
- [ ] `.env` files added to `.gitignore`
- [ ] Firebase security rules tested and deployed
- [ ] Error monitoring configured
- [ ] Analytics enabled
- [ ] Budget alerts configured
- [ ] CI/CD workflows tested
- [ ] Documentation updated
- [ ] Backup procedures in place
- [ ] Rollback plan documented

---

**Last Updated**: 2025-10-03

**Maintained by**: Fellowship Access Montana Team
