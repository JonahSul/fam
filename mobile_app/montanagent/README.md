# MontaNAgent – AI Recovery Companion

## Overview

MontaNAgent delivers an agentic AI experience for Fellowship Access Montana members. The Flutter client surfaces a compassionate chat interface while an external GenKit service brokers requests to Anthropic Claude 4 Sonnet.

### Key capabilities

- 🤖 Conversational recovery support powered by Claude 4 Sonnet via GenKit
- 🔐 Firebase Authentication (anonymous and email/password)
- 💾 Firestore-backed persistent chat history
- 📱 Flutter multi-platform (iOS, Android, Web, Desktop)
- ☁️ Standalone Node.js GenKit bridge service with Anthropic integration

## Architecture

```text
Flutter UI ──> ChatService (HTTP) ──> GenKit Service ──> Anthropic Claude 4 Sonnet
                 │                         │
                 └────── Firestore <───────┘
```

- `mobile_app/montanagent` – Flutter application
- `genkit-service` – Node.js/TypeScript service exposing `/chat` and `/health`

## Prerequisites

- Flutter SDK 3.22+
- Node.js 20+
- Firebase project with Authentication and Firestore enabled
- Anthropic API key with access to Claude 4 Sonnet

## Setup

### 1. GenKit service

```bash
cd genkit-service
cp .env.example .env # add ANTHROPIC_API_KEY
npm install
npm run build
npm start
```

The service listens on `http://localhost:3000` by default. Adjust `.env` or `PORT` as needed.

### 2. Flutter app

```bash
cd mobile_app/montanagent
flutter pub get
cp .env.template .env # update Firebase + chat settings
```

When running the app, pass the environment file as Dart defines so the chat client knows where to reach the GenKit service:

```bash
flutter run --dart-define-from-file=.env
```

For web builds you can optionally proxy requests through Firebase Hosting or another gateway. By default the app targets the URLs supplied through `CHAT_SERVICE_URL*` defines.

## Environment variables

### GenKit service (`genkit-service/.env`)

| Variable | Description |
| --- | --- |
| `ANTHROPIC_API_KEY` | Required. Anthropic API key used by the Claude plugin. |
| `PORT` | Optional. HTTP port (defaults to `3000`). |
| `NODE_ENV` | Optional. When set to `development`, verbose error details are returned. |

### Flutter app (`mobile_app/montanagent/.env`)

These values are consumed by the Flutter tool via `--dart-define-from-file`.

| Variable | Description |
| --- | --- |
| `FIREBASE_*` | Firebase identifiers (project id, API key, etc.). |
| `ANTHROPIC_API_KEY` | Used for local tooling; forwarded to GenKit if required. |
| `CHAT_SERVICE_URL` | Default GenKit endpoint for web builds. |
| `CHAT_SERVICE_URL_ANDROID` | Endpoint used when running on Android emulators (default `http://10.0.2.2:3000`). |
| `CHAT_SERVICE_URL_IOS` | Endpoint for iOS simulators. |
| `CHAT_SERVICE_URL_DESKTOP` | Endpoint for desktop platforms. |

## Running

1. Start the GenKit service (`npm start` in `genkit-service`).
2. Launch the Flutter app with `flutter run --dart-define-from-file=.env`.
3. Use the chat screen to exchange messages with MontaNAgent.

## Testing & quality

- GenKit service: `npm run build`
- Flutter unit tests: `flutter test test/unit`
- Static analysis: `flutter analyze`

## Troubleshooting

| Issue | Resolution |
| --- | --- |
| Chat requests fail with 500 | Ensure `ANTHROPIC_API_KEY` is set and the GenKit service is running. |
| Mobile emulator cannot reach service | Update `CHAT_SERVICE_URL_ANDROID`/`IOS` to point at your host machine (e.g., via `10.0.2.2`). |
| Flutter build errors | Run `flutter clean && flutter pub get`, then retry with proper Dart defines. |

## Contributing

1. Fork the repo and create a feature branch.
2. Run formatting, analysis, and unit tests before submitting.
3. Document new environment variables or runtime requirements in this README.
