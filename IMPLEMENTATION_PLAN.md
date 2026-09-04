# SkillUp Implementation & Agent Coordination Plan

> **Purpose:** This is the central working document for AI agents and developers contributing in this folder. Read it before changing code, update it when a task status changes, and keep implementation decisions traceable here.
>
> **Last updated:** 2026-09-04  
> **Project root:** `C:\Flutter projects\skillup`  
> **Current phase:** Flutter-to-FastAPI integration

---

## 1. Project Overview

### Product purpose

SkillUp is a mobile marketplace for local home services. Customers discover and book skilled professionals; workers create professional profiles, accept jobs, and manage their work. The app currently supports customer and worker onboarding flows, role-specific dashboards, booking-oriented screens, profiles, and animated navigation.

The immediate delivery goal is a **basic, locally working model** in which the Flutter app uses the bundled FastAPI backend and PostgreSQL/PostGIS. Payments, real document uploads, and real-time WebSocket tracking remain deliberately mocked in this first version.

### Intended users

| User | Main needs |
|---|---|
| Customer | Create an account, manage a profile/address, browse services/workers, book a service, and review booking status/history. |
| Worker | Create an account, complete a professional profile, view/accept/decline assigned jobs, and update job status. |
| Local developer / AI agent | Run the mobile app, backend, and database locally; safely extend and verify the integration. |

### Current status

The UI flow is substantially built. Local PostgreSQL 16 with PostGIS and the FastAPI backend are configured and operational. Flutter now has a shared HTTP client, secure token storage, and connected account-authentication screens. The bulk of profile, address, discovery, booking, and worker-job screens still display static/mock information and must be connected to the available API.

---

## 2. Completed Work

### Product and UI work

| Completed | Date | Notes |
|---|---:|---|
| Customer and worker role flows created | Before 2026-09-02 | Includes onboarding, sign-up, dashboards, profile, booking, and worker-job screen sets. |
| Shared router and page motion | Before 2026-09-02 | `go_router` uses custom slide transitions so pages move rather than abruptly swap. |
| Dashboard bottom navigation restored | Before 2026-09-02 | Customer and worker Home, Bookings, and Profile screens keep the navigation bar visible. The selected tab is emerald green. |
| Back-navigation behaviour improved | Before 2026-09-02 | Dashboard sub-pages pop to their previous page; customer/worker home routes return to role selection on device back. |
| Customer profile cleanup | Before 2026-09-02 | Customer-only profile no longer shows worker-only jobs/acceptance details. |
| Worker profile UI content | Before 2026-09-02 | Includes skills (Plumbing and Carpentry) and job acceptance-rate presentation. |
| Flutter networking dependencies added | 2026-09-03 | `dio` and `flutter_secure_storage` added to `pubspec.yaml`. |
| Shared API/session/auth foundation added | 2026-09-03 | `lib/config/api_config.dart`, `lib/services/api_client.dart`, `lib/services/session_service.dart`, and `lib/services/auth_service.dart`. |
| Account screens connected to auth API | 2026-09-03 | Customer sign-up, worker sign-up, login, OTP verification/resend, and terms acceptance call `/api/v1` endpoints. Development OTP is `123456`. |
| Customer profile and address integration | 2026-09-04 | Connected `CustomerProfileScreen` and `AddressSetupScreen` to API. Added `CustomerProfile`, `CustomerMetrics`, `CustomerAddress` typed models and `CustomerService`. Hardened `ApiClient` with List responses, delete method, and empty token check. |
| Worker profile and professional setup | 2026-09-04 | Connected `WorkerFormScreen` and `WorkerAccountProfileScreen` to API. Added `SkillCategory`, `WorkerProfile`, and `WorkerProfileUpdatePayload` models and `WorkerService`. Wired skill category fetching, profile updates, availability toggle, and live profile metrics. Local mock document upload preserved. |
| Service discovery integration | 2026-09-04 | Connected `CategoriesScreen`, `ServiceListingScreen`, `ServiceDetailsScreen`, `SearchFilterScreen`, and `NearbyWorkersScreen` to `/categories`, `/services`, `/services/{id}`, `/search`, and `/workers/nearby`. Added `ServiceModel`, `SearchResult`, `WorkerSearchItem`, `NearbyWorkerItem`, and `DiscoveryService`. Introduced `BookingFlowState` to ensure category/service/worker identities survive navigation into booking flows. |
| Booking creation and customer bookings | 2026-09-04 | Connected `BookingScheduleScreen`, `BookingReviewScreen`, `PaymentCheckoutScreen`, `BookingConfirmationScreen`, `ActiveBookingScreen`, `BookingHistoryScreen`, `CancelRescheduleScreen`, `OrderSummaryScreen`, `InvoiceSuccessScreen`, `RatingReviewScreen`, and `RebookScreen` to API. Added `QuoteRequestPayload`, `QuoteModel`, `BookingCreatePayload`, `BookingModel`, `BookingTrackingModel`, `ReviewCreatePayload`, `ReviewModel`, `InvoiceModel`, and `BookingService`. Full quote-to-booking flow, tracking, history tabs, cancellation, reschedule, rebook, invoice, and review wired with loading/error/empty states. Preserved mock payments and document uploads per Phase 1 scope. |
| Worker jobs integration | 2026-09-04 | Connected `WorkerBookingsScreen`, `HomeScreen`, and `WorkerStatusScreen` to API. Added `WorkerMetrics` model and extended `WorkerService` (`GET /worker/bookings`, `POST /worker/bookings/{id}/accept`, `POST /worker/bookings/{id}/decline`, `PATCH /worker/bookings/{id}/status`, `GET /worker/metrics`). Full worker job lifecycle (Requests, Active, History), accept/decline, multi-step status progression (`CONFIRMED` -> `ON_THE_WAY` -> `IN_PROGRESS` -> `COMPLETED`), earnings/performance dashboard, and verification checklist operational. |
| Backend login & role-based routing | 2026-09-04 | Connected `LoginScreen` to `AuthService.login` (`POST /auth/login`). JWT token persisted via `SessionService`, and user role is decoded to route customers directly to `/customer-home` and workers to `/home`. Invalid credentials surface user-friendly error banners. |
| Duplicate worker-account handling | 2026-09-04 | Hardened worker registration against duplicate phone/email collisions (`select(User).where(or_(User.phone == req.phone, User.email == req.email))`). Returns HTTP 409 Conflict with descriptive message; `WorkerSignupScreen` displays error SnackBar and offers a direct link to the sign-in screen. |
| USB API connectivity | 2026-09-04 | Documented and verified Android USB reverse port forwarding (`adb reverse tcp:8000 tcp:8000`). Physical Android devices connected via USB route `http://127.0.0.1:8000/api/v1` to the host machine without requiring LAN IP configuration or firewall adjustments. |
| End-to-end flow validation and local run guide | 2026-09-04 | Implemented automated multi-role end-to-end test suite (`test/end_to_end_flow_test.dart`) covering Customer Discovery -> Schedule -> Review Quote -> Active Tracking -> Worker Dashboard -> Rating & Review. Documented repeatable local startup & shutdown procedures and manual verification acceptance checklist. Verified 83/83 Flutter tests, 0 analyzer issues, and 8/8 backend pytest tests passing. |
| Customer Home dynamic services & pull-to-refresh | 2026-09-04 | Upgraded `CustomerHomeScreen` to dynamic `StatefulWidget` with `RefreshIndicator` and live category fetching via `DiscoveryService` (`GET /categories`). Added clean offline/error card with "Retry" action and verified on physical Android device over USB reverse proxy. Full test suite: 85/85 passing. |

### Backend and database work

| Completed | Date | Notes |
|---|---:|---|
| Backend copied into this workspace | 2026-09-02 | Located in `backend/`; based on the SkillUp FastAPI backend repository. |
| Python backend environment created | 2026-09-02 | `backend/.venv` contains Python 3.11 dependencies. |
| Backend dependency defect resolved | 2026-09-03 | Added `email-validator>=2.0.0` to `backend/requirements.txt`; FastAPI/Pydantic email schema loading now works. |
| PostgreSQL 16 service installed and started | 2026-09-03 | Local service name: `postgresql-x64-16`. |
| PostGIS 3.6 installed and enabled | 2026-09-03 | `skillup_db` has `postgis` extension enabled; geographic Point columns use SRID 4326. |
| Local database created | 2026-09-03 | Database: `skillup_db`. Configuration is in ignored `backend/.env`. Never commit this file. |
| Initial Alembic migration generated and corrected | 2026-09-03 | `backend/alembic/versions/00127c55fc01_initial_skillup_schema.py`. Corrected generated references to custom geometry type and excluded PostGIS-owned `spatial_ref_sys`. |
| Schema migration and seed data applied | 2026-09-03 | Schema is live. Seeded categories: Plumbing, Electrical, Carpentry, Appliance Repair; seeded example services. |
| API server started and health verified | 2026-09-03 | `GET /api/v1/health` returned `status: ok` and `database_status: connected`. |

### Resolved dependencies and integrations

- Flutter/Dart SDK constraint: `^3.11.4`.
- Flutter packages: `go_router`, `google_fonts`, `dio`, `flutter_secure_storage`, and `flutter_launcher_icons`.
- Backend: FastAPI, Pydantic v2, SQLAlchemy async, Alembic, asyncpg, psycopg2, GeoAlchemy2, JWT, and password hashing.
- Local persistence: PostgreSQL 16 + PostGIS 3.6.

---

## 3. In-Progress Work

| Work item | Status | Progress | Current challenge / hand-off detail |
|---|---|---:|---|
| Account/auth integration | Completed | 100% | Customer & worker sign-up, login with role-based routing, OTP verification (`123456`), duplicate worker account handling, and terms acceptance are backend-connected. |
| Customer profile and addresses | Completed | 100% | Profile reads `/customers/me/profile` and `/customers/me/metrics`; addresses create/list/delete via `/addresses`; loading, error, and retry states operational. |
| Worker profile/setup | Completed | 100% | Live skills and profile wired to `/skill-categories` and `/workers/me/profile`. Skill selection, availability toggle, bio, hourly rate, and verification badge functional. |
| Discovery and booking flow | Completed | 100% | Discovery screens (`/categories`, `/services`, `/services/{id}`, `/search`, `/workers/nearby`) and full customer booking lifecycle connected 100% (`/bookings/quote`, `/bookings`, `/bookings/{id}`, `/bookings/{id}/tracking`, `/bookings/{id}/cancel`, `/bookings/{id}/reschedule`, `/bookings/{id}/rebook`, `/bookings/{id}/invoice`, `/bookings/{id}/review`). |
| Worker jobs | Completed | 100% | `WorkerBookingsScreen`, `HomeScreen`, and `WorkerStatusScreen` connected 100% to `/worker/bookings`, `/worker/bookings/{id}/accept`, `/worker/bookings/{id}/decline`, `/worker/bookings/{id}/status`, and `/worker/metrics`. Accept, decline, step-by-step status progression, and dashboard metrics verified. |
| End-to-end validation & run guide | Completed | 100% | Automated multi-role test suite (`test/end_to_end_flow_test.dart`) passing; full Flutter test suite (83/83) passing; `flutter analyze` 0 issues; backend pytest 8/8 passing. Startup, shutdown, and USB connectivity guide documented. |

### Known blockers and risks

- **Device networking:** Android emulator uses `http://10.0.2.2:8000/api/v1`; physical devices connected over USB can run `adb reverse tcp:8000 tcp:8000` to access `http://127.0.0.1:8000/api/v1`; WiFi/LAN connections use `--dart-define=API_BASE_URL=http://<computer-LAN-IP>:8000/api/v1`.
- **Generated migration caution:** Never autogenerate a replacement migration against a database with PostGIS without reviewing it. Alembic can incorrectly try to manage `spatial_ref_sys` or reference custom types by an invalid module path.
- **UI mock/static state:** Many screens use fixed text and route-only navigation. Do not claim a flow is backend-connected until it reads/writes API data and errors are visible to the user.
- **API coverage gap:** The backend README mentions a WebSocket tracking stream, but no real WebSocket route has been verified in the router; keep tracking mocked unless such a route is implemented and tested.

---

## 4. Remaining Tasks & Next Steps

### Critical path

Execute in the listed order. Estimate assumes one agent familiar with the existing code.

| Priority | Task | Estimate | Dependencies | Acceptance criteria |
|---:|---|---:|---|---|
| P0 | Verify and harden API foundation | 1–2 h | Backend running | `ApiClient` supports map **and list** responses, surfaces API errors clearly, does not send an empty token, and base URL instructions work for emulator and physical device. |
| P0 | Connect customer profile and address setup | 3–5 h | Auth, API client | Profile loads name/email/phone from API; address form creates/lists a default address; errors and loading states are shown; screen no longer relies on static account data as source of truth. |
| P0 | Connect worker profile and professional setup | 4–6 h | Auth, categories API | Worker form saves bio, hourly rate, availability, payout preference, and skill category IDs; worker profile reads API data; local mock document stage stays explicit. |
| P0 | Connect service discovery | 4–6 h | Seed data, API list support | Categories and services load from `/categories` and `/services`; category filtering/search works; selected service identity survives navigation. |
| P0 | Connect booking creation and customer bookings | 6–10 h | Customer address, discovery | Quote then create booking with real IDs; booking list/detail/tracking refresh use backend; cancellation/reschedule/rebook/review operate and show success/error states. Payments remain mocked. |
| P0 | Connect worker jobs | 4–6 h | Worker profile and bookings | Worker sees assigned jobs, can accept/decline, and can update status with a refreshed UI. |
| P0 | End-to-end validation and run guide | 3–5 h | All P0 integration tasks | Customer and worker happy paths work against local API/database; `flutter analyze`, backend tests, and manual acceptance checklist pass; setup notes are accurate. |

### Nice-to-have / follow-up work

| Priority | Task | Estimate | Dependencies | Acceptance criteria |
|---:|---|---:|---|---|
| P1 | Replace mock current location | 4–8 h | Location package and permissions | Real device location feeds address/matching coordinates with consent and failure handling. |
| P1 | Persistent session and route guard | 3–5 h | Session storage | App restores a valid session after restart and redirects signed-out users appropriately. |
| P1 | Test data/dev tooling | 2–4 h | API/database | A repeatable seed/reset workflow creates customer/worker/booking demo data without manual SQL. |
| P1 | Backend test expansion | 6–10 h | Stable API behaviours | Authentication, authorization, booking status rules, and geo queries have focused tests. |
| P2 | Production payments | 12–20 h | Provider choice, legal/product approval | Provider-backed payment intents, verification, failure/refund handling, and no card data stored by SkillUp. |
| P2 | Real document uploads | 8–14 h | Object storage choice | Signed URL upload, validation/scanning, secure access, and worker verification workflow work end-to-end. |
| P2 | Live tracking/WebSocket stream | 12–20 h | Backend realtime design | Authenticated socket, reconnection, throttling, privacy rules, and tracking UI are implemented and tested. |

### Trackable checklist

- [x] Set up PostgreSQL/PostGIS, migration, and seed data.
- [x] Add base HTTP client, secure token storage, and core auth calls.
- [x] Connect sign-up, login, OTP, and terms-confirmation UI.
- [x] Add response-list and typed model support to the Flutter API layer.
- [x] Connect customer profile and address screens.
- [x] Connect worker profile, professional setup, and skills.
- [x] Connect categories, services, search, and nearby worker screens.
- [x] Connect quote, booking creation, booking list/details, cancellation, reschedule, review, and invoice screens.
- [x] Connect worker job list, acceptance/decline, and job status updates.
- [x] Add loading, empty, error, and retry states on every remote-data screen.
- [x] Run end-to-end customer and worker manual tests against the local stack.
- [x] Document repeatable local startup and shutdown procedures.

---

## 5. Technical Architecture & Design Decisions

### Stack and folder map

```text
skillup/
├── lib/
│   ├── config/             # API endpoint configuration
│   ├── models/             # UI/domain models (some existing temporary state)
│   ├── router/             # GoRouter configuration and slide transitions
│   ├── screens/            # Customer, worker, onboarding, booking, and profile UI
│   ├── services/           # Dio API client, session storage, auth; add feature services here
│   ├── theme/              # Emerald theme and design tokens
│   └── widgets/            # Shared visual components
├── backend/
│   ├── app/api/v1/         # FastAPI route modules
│   ├── app/models/         # SQLAlchemy entities
│   ├── app/schemas/        # Pydantic request/response contracts
│   ├── app/services/       # Business logic
│   ├── alembic/versions/   # Versioned database schema migrations
│   ├── scripts/            # Seed/maintenance scripts
│   └── tests/              # Backend automated tests
└── IMPLEMENTATION_PLAN.md  # This coordination document
```

### Flutter conventions

- Use `GoRouter` routes defined in `lib/router/app_router.dart`; retain the existing `CustomTransitionPage` slide behaviour.
- Use `FlowScaffold` and `DashboardNav` from `lib/screens/flow_widgets.dart` for consistent back-navigation, app bar, and customer/worker bottom navigation.
- New remote calls belong in focused services under `lib/services/`; UI widgets should not create raw Dio instances.
- `ApiClient` attaches a JWT from `SessionService` using `Authorization: Bearer <token>`.
- Persist only session data in `flutter_secure_storage`. Do not store passwords, OTPs, or payment data.
- Preserve the existing emerald visual theme and role-dependent back/navigation behaviour.
- Prefer typed Dart models for new API responses instead of passing untyped `Map` values deep into widgets.

### Backend conventions

- API base prefix: `/api/v1`.
- Routers live in `backend/app/api/v1`; schemas belong in `backend/app/schemas`; business rules go in `backend/app/services`.
- Use async SQLAlchemy sessions and Pydantic request/response schemas. Do not perform DB queries directly inside route functions unless following an established exception.
- JWT controls role-based access. Customer and worker endpoints must verify their expected role.
- Location fields are latitude/longitude at the API boundary. Backend stores searchable Point geometry with `SRID 4326`.
- The only tracked local database schema source is Alembic migration(s), not an ad-hoc database state.

### Core API contract

| Capability | API routes |
|---|---|
| Health | `GET /health` |
| Auth/account | `POST /auth/register/customer`, `POST /auth/register/worker`, `POST /auth/login`, `POST /auth/otp/send`, `POST /auth/otp/verify`, `POST /auth/password/reset`, `POST /auth/logout`, `GET/PATCH /me`, `POST /me/terms-acceptance` |
| Customer | `GET /customers/me/profile`, `GET /customers/me/metrics`, `GET/POST /addresses`, `PATCH/DELETE /addresses/{addressId}` |
| Discovery | `GET /categories`, `GET /services`, `GET /services/{serviceId}`, `GET /search`, `GET /locations/search`, `GET /locations/reverse-geocode`, matching routes |
| Bookings | `POST /bookings/quote`, `POST/GET /bookings`, `GET/PATCH /bookings/{bookingId}`, cancellation/rescheduling/tracking/rebook/review/invoice subroutes |
| Worker profile | `GET/PATCH /workers/me/profile`, `GET /skill-categories`, verification/document mock routes, public worker/review routes |
| Worker jobs | `GET /worker/jobs`, `POST /worker/jobs/{bookingId}/accept`, `POST /worker/jobs/{bookingId}/decline`, `PATCH /worker/jobs/{bookingId}/status`, metrics route |

Read `backend/SKILLUP_API_ENDPOINTS.md` and Pydantic schema files before adding a feature; the schema is the authoritative payload definition.

### Data model summary

- `users`: common authentication and role fields (`CUSTOMER` / `WORKER`).
- `customer_profiles` and `customer_addresses`: profile and saved geographic addresses.
- `worker_profiles`, `worker_skills`, `worker_documents`, `worker_payout_accounts`: professional profile, skills, verification, and payout metadata.
- `skill_categories`, `services`: service catalogue.
- `bookings`, `booking_status_history`, `reviews`: booking lifecycle and customer reviews.
- `otp_verifications`, `terms_acceptances`: onboarding/account audit data.

### Explicit first-version mocks

- OTP provider: backend development code is `123456`; replace before any public deployment.
- Payment checkout/invoice UI: no payment provider integration.
- Worker documents: API can issue a mock presigned upload URL; no real object-store upload pipeline.
- Tracking: UI/API refresh can be used; do not promise live websocket tracking until implemented.

---

## 6. Environment & Setup Requirements

### Required local tooling

| Tool | Required version / notes |
|---|---|
| Flutter | Compatible with Dart `^3.11.4`; use the project’s installed Flutter SDK. |
| Python | 3.11.x is the local backend runtime. |
| PostgreSQL | 16.x local service. PostgreSQL 15+ is compatible with the backend. |
| PostGIS | 3.6.x currently installed; mandatory for geographic tables. |
| Android emulator / device | Emulator can use `10.0.2.2`; physical device needs LAN base URL configuration. |

### Configuration and secret handling

- Copy `backend/.env.example` to `backend/.env` for new environments.
- `backend/.env` is ignored by Git. It contains local DB credentials and must never be committed, pasted in agent messages, or recorded in screenshots.
- Use `API_BASE_URL` only through a Dart define, never hard-code a personal LAN IP in source:

```powershell
flutter run --dart-define=API_BASE_URL=http://<computer-LAN-IP>:8000/api/v1
```

- Defaults in `lib/config/api_config.dart`:
  - Android: `http://10.0.2.2:8000/api/v1`
  - Desktop: `http://127.0.0.1:8000/api/v1`

### Physical device USB reverse port forwarding

When debugging on a physical Android phone connected via USB:
1. Enable USB debugging on the Android device.
2. Run reverse port forwarding from terminal:
```powershell
adb reverse tcp:8000 tcp:8000
```
3. Run the app without needing LAN IP changes:
```powershell
flutter run
```
The app running on the physical phone can now resolve `http://127.0.0.1:8000/api/v1` through the host development machine without firewall or subnet barriers.

### Local startup procedure

1. Ensure the PostgreSQL service is running and `skillup_db` has the PostGIS extension:
```powershell
Get-Service postgresql-x64-16
```
2. From `backend/`, activate/use `.venv`, install dependencies, then apply migrations:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m alembic upgrade head
.\.venv\Scripts\python.exe scripts\seed_categories.py
```

3. Start the backend:

```powershell
.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

4. Confirm it works:

```powershell
curl http://127.0.0.1:8000/api/v1/health
```

5. From project root, install Flutter packages and run:

```powershell
flutter pub get
flutter analyze
flutter run
```

### Local shutdown procedure

1. Stop Flutter app: press `q` in the Flutter run terminal.
2. Stop FastAPI backend: press `Ctrl + C` in the uvicorn terminal.
3. Stop PostgreSQL service (optional):
```powershell
Stop-Service postgresql-x64-16
```


### Build, test, and deployment baseline

- Flutter static check: `flutter analyze`.
- Flutter tests: `flutter test` (add feature tests as work proceeds).
- Backend tests: from `backend/`, `.\.venv\Scripts\python.exe -m pytest -v`.
- Backend API docs: `http://127.0.0.1:8000/docs`.
- No production deployment is configured. Before deployment, replace development JWT secrets, permissive CORS, fixed OTP, local database credentials, and mock external services.

---

## 7. Collaboration Guidelines for Other AI Agents

### Rules before editing

1. Read this file, `git status --short`, and the target screen/service/schema before editing.
2. Treat existing uncommitted changes as user work unless the task clearly owns them. Do not reset, discard, or broadly reformat unrelated files.
3. Keep a change focused to one feature slice whenever possible: service/model → screen → test → plan update.
4. Do not duplicate routes, services, or model names. Search first.
5. Do not place secrets in source code, Markdown, commits, screenshots, or agent hand-offs.

### Naming and coding standards

- **Dart:** `snake_case.dart` file names, `PascalCase` types, `camelCase` members. Run `dart format` on changed Dart files.
- **Python:** `snake_case.py` files/functions, `PascalCase` classes. Keep type hints and Pydantic schemas aligned with actual API payloads.
- **Routes:** preserve existing kebab-case Flutter routes and `/api/v1` backend paths.
- **UI:** use `AppTheme`, `FlowScaffold`, `AppCard`, and existing flow widgets rather than introducing unstyled one-off patterns.
- **Errors:** remote screens must provide loading, empty, error, and retry handling; never silently fall back to fake data after an API error.
- **Documentation:** explain non-obvious API/DB design decisions in a short code comment or in this plan’s decision log.

### Updating this plan

When finishing a task:

1. Change its checkbox/table row status and percent in Sections 2–4.
2. Add a dated entry to the Completed Work table with files/routes affected.
3. Add a concise entry to the Decision & Issue Log below if the work changes architecture, API shape, migration behaviour, or scope.
4. Record exact verification commands and their result in the hand-off message/PR summary.

When blocked:

1. Add the blocker to Section 3 with what was tried and the exact next required input/decision.
2. Do not invent API fields, credentials, production providers, or destructive database actions.
3. Leave the working tree in a buildable state when feasible.

### Handoff protocol

Use this format in a final note or commit/PR description:

```text
Feature: <one sentence>
Changed: <key files/routes>
Verified: <commands and outcomes>
Known limitation: <if any>
Next owner: <specific next task>
```

### Scope for Antigravity and other agents

**Antigravity:** Take one isolated P0 feature at a time. Recommended first assignment: customer profile and address API integration. It should add typed request/response models and a focused profile/address service, wire `CustomerProfileScreen` and `AddressSetupScreen`, add user-visible async states, run `dart format`/`flutter analyze`, then update this plan. Do **not** alter global navigation transitions, delete user changes, change database credentials, or implement payments/documents/live tracking.

**Other agents:**

- Discovery agent: categories/services/search/worker selection only after typed list response support exists.
- Booking agent: quote/create/list/detail/status/review flow only after discovery and customer address selection use actual IDs.
- Worker-jobs agent: worker job list, accept/decline/status after worker profile setup is API-backed.
- Backend agent: migrations, endpoint defects, seed tooling, and pytest coverage; coordinate any schema/payload change before Flutter work begins.

### Decision & Issue Log

| Date | Decision / issue | Outcome |
|---|---|---|
| 2026-09-03 | Initial Alembic autogeneration included invalid module references for custom geometry and attempted to manage `spatial_ref_sys`. | Corrected the initial migration manually. Future migrations require review before applying. |
| 2026-09-03 | Backend could not load Pydantic email schema. | Added `email-validator` to requirements. |
| 2026-09-03 | Scope for first working version. | Payments, real document storage, and live WebSocket tracking remain mocked. |
| 2026-09-04 | Customer profile & address data source of truth | Replaced static `CustomerAccount` UI state with `CustomerService` backed by `/customers/me/profile`, `/customers/me/metrics`, and `/addresses`. Added list response, delete method, and empty token guard to `ApiClient`. Added `aiosqlite` to backend requirements for async SQLite pytest suite. |
| 2026-09-04 | Worker profile and professional setup integration | Bound `WorkerFormScreen` and `WorkerAccountProfileScreen` to `WorkerService` (`/workers/me/profile`, `/skill-categories`). Mapped skills to backend UUIDs with experience years. Live profile displays progress, verification status badge, skills, bio, rate, and availability toggle. Local document upload mock preserved per Phase 1 scope. |
| 2026-09-04 | Service discovery & flow identity preservation | Bound `CategoriesScreen`, `ServiceListingScreen`, `ServiceDetailsScreen`, `SearchFilterScreen`, and `NearbyWorkersScreen` to `DiscoveryService` (`/categories`, `/services`, `/services/{id}`, `/search`, `/workers/nearby`). Added `BookingFlowState` singleton and GoRouter query parameters to preserve category/service/worker identity into booking flows. |
| 2026-09-04 | Booking creation and customer bookings integration | Bound all 11 customer booking flow screens to `BookingService` (`POST /bookings/quote`, `POST /bookings`, `GET /bookings`, `GET /bookings/{id}`, `GET /bookings/{id}/tracking`, `POST /bookings/{id}/cancel`, `POST /bookings/{id}/reschedule`, `POST /bookings/{id}/rebook`, `GET /bookings/{id}/invoice`, `POST /bookings/{id}/review`). Integrated `BookingFlowState` singleton to carry quote/booking context smoothly across screens. Payment checkout remains mock per Phase 1 scope. |
| 2026-09-04 | Worker jobs integration & status progression | Bound `WorkerBookingsScreen`, `HomeScreen`, and `WorkerStatusScreen` to `WorkerService` (`/worker/bookings`, `/worker/bookings/{id}/accept`, `/worker/bookings/{id}/decline`, `/worker/bookings/{id}/status`, `/worker/metrics`). Supported 3 job segments (Requests, Active, History), accept/decline state mutation, sequential status progression (`CONFIRMED` -> `ON_THE_WAY` -> `IN_PROGRESS` -> `COMPLETED`), and live dashboard performance metrics. |
| 2026-09-04 | Backend login & role routing | Wired `LoginScreen` to `AuthService.login` (`POST /auth/login`). Persisted token via `SessionService` and dispatched user directly to `/customer-home` or `/home` based on role field in response. Handled 401 Unauthorized with readable error banners. |
| 2026-09-04 | Duplicate worker-account collision handling | Verified backend phone/email duplicate registration guards (`ConflictException` 409). Ensured `WorkerSignupScreen` displays user-friendly collision feedback and provides seamless navigation to the sign-in flow. |
| 2026-09-04 | Physical Android device USB API connectivity | Configured reverse port proxy workflow (`adb reverse tcp:8000 tcp:8000`) for development. Allows physical phones attached via USB to connect directly to `http://127.0.0.1:8000/api/v1` without hardcoding personal LAN IP addresses. |
| 2026-09-04 | End-to-end validation and local run guide completion | Built automated multi-role end-to-end test suite (`test/end_to_end_flow_test.dart`) covering customer booking lifecycle, active tracking, worker dashboard, status updates, and customer ratings. Documented repeatable local startup and shutdown procedures. Verified 83/83 tests passing, `flutter analyze` 0 issues, and 8/8 backend tests passing. |
| 2026-09-04 | Customer Home dynamic services & pull-to-refresh | Converted `CustomerHomeScreen` to a `StatefulWidget` fetching live categories via `DiscoveryService`. Integrated `RefreshIndicator` with `AlwaysScrollableScrollPhysics` and resilient error card with "Retry" action. Verified 85/85 tests and physical USB debugging flow. |

---

## 8. Testing & Quality Assurance Plan

### Test strategy

| Level | Coverage target | Tool / approach |
|---|---|---|
| Unit | Dart model parsing, API service payloads/error mapping, backend business rules, booking status validation | `flutter test`; `pytest` |
| Integration | Auth → token persistence → authenticated profile/address; service discovery → booking quote/create; worker job mutations | Local FastAPI + PostgreSQL/PostGIS test database or isolated local test data |
| UI / end-to-end | Customer and worker happy paths, back behaviour, dashboard navigation persistence, errors/retries | Android emulator manual test initially; add `integration_test` where stable |
| Regression | Router paths, static analysis, migration upgrades, health endpoint | `flutter analyze`, `flutter test`, `pytest -v`, `alembic upgrade head`, health request |

### Minimum manual acceptance flows

- [ ] Customer creates account, receives/uses development OTP `123456`, accepts terms, and reaches customer home.
- [ ] Customer signs in after app restart and profile details match backend data.
- [ ] Customer saves an address, browses seeded services, requests a quote, creates a booking, and sees it in booking history.
- [ ] Customer cancels/reschedules/rebooks/reviews an eligible booking and receives clear status feedback.
- [ ] Worker creates account, verifies OTP, saves a professional profile and skills, and sees saved values in profile.
- [ ] Worker accepts/declines an offered job and status changes persist after refresh.
- [ ] Customer and worker bottom navigation remain visible and highlight the active tab.
- [ ] Device/system Back returns to the intended preceding page; worker/customer home Back returns to role selection.
- [ ] Failed API responses show a readable error and retry path without crashing or displaying stale mock data as real.

### Known bugs and technical debt

- Existing profile, address, discovery, booking, and worker job screens still contain static/demo content.
- Flutter API client currently focuses on JSON object responses; extend it carefully for JSON lists and typed decoding before discovery/bookings.
- No automated Flutter integration tests are in place yet.
- Backend migration was generated locally and manually corrected; add CI validation from a fresh empty PostGIS database.
- Development defaults are insecure for production: fixed OTP, broad CORS, development secret, and local-only service configuration.
- `CustomerAccount` is transitional UI state and must not remain the authoritative account data source after profile integration.

### Quality targets

- `flutter analyze` completes with no errors for changed code.
- Backend `pytest -v` passes before hand-off; new API behaviour gets focused tests.
- API calls should show a visible progress state within 200 ms where practical and have timeouts/error messaging.
- Preserve smooth page transitions and avoid blocking the UI thread.
- Accessibility: every interactive control has a visible label; maintain readable contrast; support text scaling; provide keyboard types for phone/OTP/numeric fields; tap targets should be approximately 48 dp or larger.
- Do not log tokens, passwords, OTP values (except the documented local development OTP), address coordinates beyond required debugging, or sensitive documents.

