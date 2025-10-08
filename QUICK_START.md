# Quick Start Guide

Get all components running in 30 minutes.

## Prerequisites

```bash
# Required tools
node --version  # 20.x+
flutter --version  # 3.22.0+
npm install -g firebase-tools expo-cli
```

## Setup

### 1. API Keys (10 min)
- **Firebase**: Create project, enable Auth/Firestore/Functions
- **Gemini**: Get API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

### 2. MCP Tool (5 min)
```bash
cd mcp-tool
npm install
cat > .env << 'EOF'
BMLT_API_BASE=https://bmlt.mtrna.org/prod
SERVER_VERSION=0.0.1
LOG_LEVEL=debug
EOF
npm run build && node build/index.js
```

### 3. FAM App (10 min)
```bash
cd fam-app
npm install && cd functions && npm install && cd ..
# Add Firebase config to .env
firebase login && firebase use --add
firebase deploy --only firestore:rules,firestore:indexes
cd functions && npm run build && cd .. && firebase deploy --only functions
npm start
```

### 4. MontaNAgent (5 min)
```bash
cd mobile_app/montanagent
flutter pub get
cat > .env << 'EOF'
GEMINI_API_KEY=your_key_here
ENABLE_DEBUG_LOGGING=true
EOF
flutter run -d chrome
```

## Verification

- **MCP**: `echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | node build/index.js`
- **FAM**: Register account, send chat message
- **MontaNAgent**: Sign in, test AI chat

## Troubleshooting

- Clear npm cache: `npm cache clean --force`
- Flutter clean: `flutter clean && flutter pub get`
- Firebase re-login: `firebase logout && firebase login`
- Check .env files for correct format (no quotes/spaces)