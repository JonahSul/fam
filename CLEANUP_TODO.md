## Cleanup TODO for montanagent (Flutter app)

This document consolidates actionable cleanup, test, and architecture work for the `mobile_app/montanagent` codebase.

### 1) Dead code to remove (not in executable/test paths)

Criteria: Anything not reachable by runtime (from `lib/main.dart` → Providers → Screens/Services) or by tests under `test/` should be removed. Keep only what is referenced by `main.dart`, `routes/app_router.dart`, screens, services wired into Providers, and tests.

- AI Provider abstractions and duplicates (not wired in DI, not referenced by UI/services/tests)
  - Delete: `mobile_app/montanagent/lib/services/ai_provider.dart`
  - Delete: `mobile_app/montanagent/lib/services/gemini_provider.dart`
  - Delete: `mobile_app/montanagent/lib/services/openai_provider.dart`
  - Delete: `mobile_app/montanagent/lib/services/gemini_service.dart`
  - Rationale: Current chat path uses `ChatService` HTTP to GenKit backend; these providers are not registered in `main.dart` and not used by any screen or test.

- Agent Mode service (not wired to providers or UI)
  - Delete: `mobile_app/montanagent/lib/services/agent_mode_service.dart`
  - Rationale: Not registered in `MultiProvider` in `main.dart`, not referenced in screens. If planned later, move into feature branch or keep a stub interface only.

- Components likely unused by current screens (verify before deletion)
  - Candidate delete: `mobile_app/montanagent/lib/components/agent_mode_toggle.dart`
  - Candidate delete: `mobile_app/montanagent/lib/components/tool_execution_widget.dart`
  - Candidate delete: `mobile_app/montanagent/lib/components/components.dart` (barrel) if nothing imports it
  - Keep: `glass/*`, `backgrounds/space_background.dart`, `theme_toggle_widget.dart`, `todo_item_widget.dart`, `gradient_border.dart` (appear used directly/indirectly by `chat_screen.dart` and `todo_list_screen.dart`)
  - Action: Run a repo-wide search for imports; if zero references (including tests), delete candidates.

- Screens audit (routed in `routes/app_router.dart`)
  - Keep: `lib/screens/auth/login_screen.dart`
  - Keep: `lib/screens/auth/register_screen.dart`
  - Keep: `lib/screens/chat_screen.dart`
  - Keep: `lib/screens/todo_list_screen.dart`
  - Keep: `lib/screens/session_list_screen.dart`
  - Keep: `lib/screens/meeting_search_screen.dart`

- Services wired at runtime (registered in `main.dart`)
  - Keep: `auth_service.dart`, `chat_service.dart`, `firestore_service.dart`, `bmlt_service.dart`, `render_quality_service.dart`, `todo_ai_service.dart`, `session_service.dart`
  - Note: `todo_ai_service.dart` calls `http://localhost:3000`; ensure env-based base URL (see Architecture section) before release. Keep for now; it’s used by `SessionService` flows.

Execution steps:
1. Delete the 5 AI provider/service files listed above.
2. Search for references to candidate components; delete if unused.
3. Run analyzer and tests to catch any hidden references.

### 2) Test-ability and test-edness (TDD plan)

Current state (quick read):
- Tests exist across unit, widget, integration, and performance: `test/unit/*`, `test/widget/*`, `test/integration/*`, `test/performance/*`.
- Dev deps include `mockito`, `firebase_auth_mocks`, `fake_cloud_firestore`, `flutter_test`.

Immediate improvements (1–2 days):
- Add DI seams to services for HTTP and base URLs
  - Inject `http.Client` into `ChatService`, `TodoAIService` to enable mocking/timeouts deterministically.
  - Move base URLs to `EnvConfig` for all platforms; pass into services via constructor.
- Write missing unit tests (top-down by critical path)
  - `ChatService`: success, 4xx/5xx, timeout, malformed JSON.
  - `TodoAIService`: success, timeout, fallback keyword path.
  - `SessionService`: starting new session, listing messages, generateTodosFromConversation happy/error paths.
  - `AuthService`: anonymous sign-in success/error (using mocks).
- Widget tests
  - `ChatScreen`: sends user message, appends AI response, shows loader, timeout path displays error.
  - `TodoListScreen`: filter chips affect list; clear completed deletes items.
- Integration
  - App boot smoke test navigates `AuthWrapper` → `Login` or `Chat`.

Process to adopt TDD going forward:
- Define Given/When/Then test for each user story before coding.
- Add a “no merge without tests” rule with minimum coverage gate (start at 60%, ratchet +5% per sprint to 80%).
- Enforce via CI: run `flutter test --coverage`; fail on coverage drop.
- Add golden tests for critical widgets (chat bubbles, todo items) to deter visual regressions.

Tooling and CI:
- Add GitHub Actions (or selected CI) workflow: flutter setup cache, `flutter analyze`, `flutter test --coverage`.
- Surface coverage report artifact; optionally use Codecov.
- Lint strictly with `flutter_lints` + a few additions (prefer_single_quotes, avoid_print, exhaustive_switches).

Test data and fakes:
- Continue using `fake_cloud_firestore` and `firebase_auth_mocks`.
- Provide seeded fixtures for sessions/messages/todos.
- Create builders for `ChatMessage`, `TodoItem`, `ChatSession` for readable test setup.

### 3) Architectural roundup and scale readiness

Current architecture (observed):
- Flutter app with `provider` for state management.
- Runtime services: Firebase Auth, Firestore, HTTP GenKit backend for AI chat (`ChatService`) and TODO analysis (`TodoAIService`).
- UI routes defined centrally in `routes/app_router.dart`. Visual layer uses glass/animated backgrounds with a `RenderQualityService` toggle.

Gaps vs current delivery and scale:
- Backend base URLs are hardcoded to localhost (and platform conditionals) in `ChatService` and `TodoAIService`.
- No typed repository layer; services mix transport concerns and domain logic.
- No retry/backoff, no circuit breaker, limited error classification.
- Message streaming not supported (full-response only); can feel slow at scale.
- Firestore usage: ensure pagination, indexes, and batched writes for sessions/messages.
- Observability: no in-app telemetry/Crashlytics links in this module.

Recommendations to go fast and scale to 10^2–10^5 users:
- Configuration
  - Centralize environment in `EnvConfig` (already present) and remove hardcoded URLs. Provide `prod`, `staging`, `dev` configs per platform. Wire into all HTTP services.
- Networking resilience
  - Introduce `http.Client` injection, add retry with exponential backoff for idempotent calls, and request timeouts.
  - Add basic circuit-breaker behavior (open on repeated failures, surface offline UX).
- Domain layering
  - Add `repositories/` with interfaces: `ChatRepository`, `TodosRepository`, `SessionsRepository`.
  - Services become thin orchestrators; UI depends on repositories via interfaces to improve testability and flexibility.
- Streaming UX
  - Support server-sent events or chunked responses for chat streaming; render partial tokens for perceived speed.
- Firestore performance
  - Ensure queries are paginated and indexed; use `limit`/`startAfter` for messages and sessions.
  - Batch writes for chat+todo generation flows where possible.
- State management
  - Provider is acceptable; consider Riverpod for finer-grained updates and testability if state hot spots emerge.
- Telemetry & feature flags
  - Add Crashlytics, simple analytics events on key flows, and remote-config/feature flags to toggle heavy features (e.g., glass effects default to balanced on low-end devices).
- Security
  - Validate all backend inputs; never send secrets from client. Ensure auth token handling on API calls if/when required.

Scale-readiness checklist (actionable):
1. Move all base URLs to `EnvConfig` and remove localhost from source.
2. Inject `http.Client` into `ChatService` and `TodoAIService`; add retries/backoff.
3. Implement repository interfaces and migrate `SessionService` to use them.
4. Add pagination to message/session queries; verify Firestore indexes (`firestore.indexes.json`).
5. Add streaming chat support and UI partial-render.
6. Add CI with analyze + tests + coverage gate; block merges on failures.
7. Add Crashlytics and minimal analytics events; wire feature flags for heavy UI.
8. Profile startup and chat send on low-end devices; use `RenderQualityService` defaults accordingly.

Notes on removals vs future work:
- If Agent Mode is a near-term feature, keep only a minimal interface and move implementation to a separate package or feature branch to avoid shipping dead code.

Owner next actions (proposed sprint backlog):
- PR A: Remove dead AI provider files and unused components; wire env URLs; add DI seams.
- PR B: Unit/widget test suite expansion; add CI workflow with coverage gate.
- PR C: Introduce repositories and pagination; add retries/backoff.
- PR D: Streaming chat and UX improvements; observability/flags.


