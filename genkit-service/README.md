# FAM GenKit Service

This package exposes a lightweight HTTP service that brokers chat requests between the MontaNAgent app and the Anthropic Claude models via Genkit.

## Prerequisites

- Node.js 20+
- An Anthropic API key with access to Claude 4 Sonnet (set `ANTHROPIC_API_KEY` in `.env`)

## Setup

```bash
npm install
cp .env.example .env # update the values inside
npm run build
npm start
```

The service starts on port `3000` by default. Use the `/health` endpoint to confirm readiness.

## Endpoints

- `GET /health` — simple health probe
- `POST /chat` — accepts `{ message, userId }` and returns a Claude-generated reply

## Environment Variables

| Variable | Description |
| --- | --- |
| `ANTHROPIC_API_KEY` | Required. Anthropic API key used by the Genkit Anthropic plugin. |
| `PORT` | Optional. Server port (defaults to `3000`). |
| `NODE_ENV` | Optional. Enables verbose error responses when set to `development`. |

## Development Notes

- Restart the service after making TypeScript changes or run `npm run build` for a production build.
- The service logs each request and truncates the payload to avoid leaking sensitive data.
- Errors from Claude are surfaced as HTTP 500 responses with a generic message (detailed info appears only in development mode).
