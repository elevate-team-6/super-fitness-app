<div align="center">

# 🏋️🤖 Super Fitness

**An AI-powered fitness companion built with Flutter — workouts, nutrition, and a coach that actually knows your catalog.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.5+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-success)](#-architecture)
[![State](https://img.shields.io/badge/State-Bloc%2FCubit-blueviolet)](https://bloclibrary.dev)
[![Tests](https://img.shields.io/badge/Tests-45%20suites-brightgreen)](#-testing)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](#-cicd)
[![OTA](https://img.shields.io/badge/OTA-Shorebird-orange)](https://shorebird.dev)

</div>

---

## 📸 Screenshots

Below are the app's screenshots that highlight its functionality:

<img width="1881" height="836" alt="Image" src="https://github.com/user-attachments/assets/70145bd4-e57e-469e-8385-72cca3762079" />

---

## 📖 Overview

Super Fitness is a production-grade Flutter application that combines a **workout catalog**, a **nutrition library**, and an **AI fitness coach** into a single bilingual (English 🇬🇧 / Arabic 🇸🇦) experience.

What makes it different from a typical fitness app: the AI coach is **grounded in a local SQLite catalog**. Instead of hallucinating exercises, the model calls real search tools against an on-device database of exercises and meals, then answers using only what actually exists in the app — with tappable reference cards linking straight to the exercise details screen.

---

## ✨ Features

### 🔐 Authentication
- Email/password **sign-up** and **sign-in** backed by the Elevate Fitness API
- **Social login** via Google and Facebook, with automatic profile completion for new social accounts
- **Forgot password** flow: email → OTP verification → password reset
- **Change password** from within the app
- Tokens stored in `flutter_secure_storage` and injected automatically by a Dio interceptor

### 🏠 Home / Explore
- Personalized greeting powered by cached user data (instant paint, no network wait)
- **Popular training** exercises, **muscle recommendations**, **meal categories**, and upcoming workout sections
- Skeleton loaders (`skeletonizer`) instead of spinners for perceived performance
- Per-request cache durations driven by a custom Dio cache interceptor

### 💪 Workouts
- Browse by **muscle group → muscle → difficulty level → exercise**
- 8 difficulty tiers (Beginner → Legendary), filtered by prime-mover muscle
- Rich **exercise details**: demo/explainer video, target muscles, required equipment, and a technical spec grid (posture, grip, laterality, mechanics, force type, and more)

### 🥗 Nutrition
- Meal categories and per-category browsing (TheMealDB)
- **Meal details** with a full ingredient list and measurements
- Served through a separate, token-free Dio instance so third-party calls never carry your auth header

### 🤖 AI Coach (Chat)
- Multi-session chat with **persistent history** stored locally in Hive
- **Tool-calling loop**: the model invokes `search_exercises`, `search_meals`, and text-search tools against the on-device catalog before answering
- **Retrieval relaxation ladder** — if a strict filter set returns nothing, constraints are progressively loosened instead of failing
- **Fast-path classifier** to skip the tool loop for simple conversational turns
- User context injection (age, gender, goal, activity level) so answers are personalized
- **Degraded-mode service** for graceful behavior when the AI backend is unreachable
- Reference carousel: every recommended exercise renders as a card that deep-links into the app

### 👤 Profile
- Profile data with local caching and pull-to-refresh
- **Edit profile** (name, email, phone, gender, age, weight, height, goal, activity level) and avatar upload via `image_picker`
- In-app **WebView** for Security, Privacy Policy, and Help pages
- Logout with confirmation dialog and full secure-storage cleanup

### 🌍 Platform & UX
- Full **English/Arabic localization** with RTL support (`easy_localization`)
- **Responsive** layouts via `flutter_screenutil` (375×812 design baseline)
- Custom dark theme, glassmorphic navigation bar, custom page transitions
- **Firebase Crashlytics** for fatal + async error reporting
- **Shorebird** over-the-air patching for hotfixes without a store release

---

## 🏗 Architecture

The project follows **Clean Architecture** with an **MVVM** presentation layer, applied per feature.

```
┌──────────────────────────────────────────────────────────┐
│  Presentation   screens · widgets · cubits (view models) │
│                 states · events                          │
├──────────────────────────────────────────────────────────┤
│  Domain         entities · repo contracts · use cases    │
├──────────────────────────────────────────────────────────┤
│  Data           models (req/res) · repo impls            │
│                 data source contracts                    │
├──────────────────────────────────────────────────────────┤
│  API / Local    Retrofit clients · remote & local        │
│                 data source implementations              │
└──────────────────────────────────────────────────────────┘
```

**Dependency rule:** every arrow points inward. Presentation depends on Domain; Data implements Domain contracts. Domain knows nothing about Dio, Hive, or Flutter.

### Key patterns

| Pattern | Implementation |
|---|---|
| **State management** | `Cubit` + a custom `BaseCubit<State, UiEvent>` that exposes a side-effect stream (toasts, navigation) separate from state |
| **Unified state** | `BaseState<T>` — `isLoading` / `data` / `errorMessage` in one immutable, `Equatable` object |
| **Event-driven cubits** | Each cubit exposes a single `doEvent(...)` entry point taking a typed event class |
| **Dependency injection** | `get_it` + `injectable` with generated `di.config.dart` |
| **Error handling** | `ApiResult<T>` result type + a centralized `ErrorHandler` that maps Dio/platform exceptions to user-facing messages |
| **Networking** | Retrofit clients over Dio, with an auth interceptor, cache interceptor, and per-request cache TTLs |
| **Two Dio instances** | Default (authenticated, `baseUrl` scoped) and `@Named('external')` (no token) for third-party APIs |

### On-device catalog

Two pre-built SQLite databases ship as assets and are installed on first launch:

```
assets/data/
├── manifest.json      # data_version + sha256 + size per database
├── exercises.db       # ~4.9 MB — exercises, muscles, equipment, movement patterns…
└── meals.db           # ~3.6 MB — meals, categories, areas, ingredients
```

`AssetInstaller` verifies each database against its **SHA-256** checksum on startup and re-copies only when the shipped asset differs from what's on disk — so shipping new data is just a matter of updating `manifest.json`.

---

## 🛠 Tech Stack

| Layer | Packages |
|---|---|
| **State** | `bloc`, `flutter_bloc`, `equatable` |
| **DI** | `get_it`, `injectable`, `injectable_generator` |
| **Network** | `dio`, `retrofit`, `dio_cache_interceptor`, `pretty_dio_logger` |
| **Serialization** | `json_annotation`, `json_serializable`, `build_runner` |
| **Local storage** | `sqflite`, `hive`, `hive_flutter`, `flutter_secure_storage`, `path_provider` |
| **Firebase** | `firebase_core`, `firebase_auth`, `firebase_crashlytics`, `firebase_remote_config`, `cloud_firestore` |
| **Auth providers** | `google_sign_in`, `flutter_facebook_auth`, `crypto` |
| **UI** | `flutter_screenutil`, `google_fonts`, `flutter_svg`, `lottie`, `cached_network_image`, `skeletonizer`, `bot_toast`, `pinput`, `pin_code_fields`, `expandable_page_view` |
| **i18n** | `easy_localization`, `intl` |
| **Misc** | `webview_flutter`, `image_picker`, `url_launcher`, `logger` |
| **Testing** | `flutter_test`, `bloc_test`, `mockito` |
| **Release** | `flutter_launcher_icons`, `flutter_native_splash`, Shorebird |

---

## 📂 Project Structure

```
lib/
├── main.dart                    # Bootstrap: Firebase, i18n, DI, DB install, initial route
├── firebase_options.dart
│
├── config/                      # Cross-cutting infrastructure
│   ├── base_cubit/              # BaseCubit with UI-event stream
│   ├── base_state/              # BaseState<T>
│   ├── base_response/           # Generic API envelope
│   ├── base_ui_event/           # Toast / navigation side effects
│   ├── base_ui_handler/         # UiEventHandlerMixin
│   ├── cache/                   # Hive + secure storage helpers
│   ├── di/                      # get_it + injectable setup
│   ├── dio/                     # Dio module (default + external clients)
│   ├── error_handler/           # ApiResult + ErrorHandler
│   ├── firebase/                # Firebase module
│   ├── interceptors/            # AuthInterceptor
│   ├── services/                # Auth, Google, Facebook, Crashlytics
│   ├── helpers/                 # Date/phone extensions
│   └── validations/             # Form validators
│
├── core/
│   ├── data/local/sqlite/       # AssetInstaller, catalog data source, DB constants
│   ├── network/                 # AI client config + exceptions
│   ├── utils/                   # Colors, styles, theme, routes, assets, endpoints, keys
│   └── widgets/                 # Shared widgets (scaffold, app bar, text field, states…)
│
└── features/
    ├── auth/                    # Login, register, social, forgot/change password
    ├── onboarding/              # First-run carousel + language switch
    ├── main_layout/             # Bottom navigation shell (4 tabs)
    ├── home/                    # Explore, food list, meal details
    ├── workouts/                # Muscle groups → muscles → levels → exercises
    ├── chat/                    # AI coach: retrieval, tools, sessions, UI
    └── profile/                 # Profile, edit profile, webviews

test/                            # 45 test suites mirroring lib/
assets/                          # images · icons · lottie_files · translations · data
.github/workflows/               # Lint, tests, PR/branch validation, distribution, OTA
```

Each feature follows the same internal shape:

```
features/<feature>/
├── api/            # api_client/ (Retrofit) + data_sources/ (implementations)
├── data/           # models/{request,response} · data_sources/ (contracts) · repo/ (impl)
├── domain/         # entities/ · repo/ (contract) · use_cases/
└── presentation/   # screens/ · widgets/ · view_model(s)/ (cubit + event + state)
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable channel) with **Dart ≥ 3.11.5**
- Android Studio / Xcode toolchains
- A Firebase project (Android + iOS apps registered)

### 1. Clone & install

```bash
git clone https://github.com/elevate-team-6/super-fitness-app.git
cd super-fitness-app
flutter pub get
```

### 2. Firebase configuration

These files are **not** committed. Obtain them from the team or generate them with the FlutterFire CLI:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
```

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3. Code generation

Retrofit clients, JSON serializers, mocks, and the DI graph are all generated. Run this after cloning and after touching any annotated file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

During active development you can keep it watching:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Remote Configuration (Secrets)

This project uses **Firebase Remote Config** to manage sensitive API keys (like Ollama) securely at runtime. This avoids embedding secrets in the binary and allows for instant key rotation without redeploying the app.

1.  Ensure you have your `google-services.json` (Android) and `firebase_options.dart` (Shared) restored.
2.  In the **Firebase Console**, go to **Remote Config** and add the following key:
    *   `OLLAMA_API_KEY`: Your actual Ollama API key.
3.  Publish the changes.

### 5. Run

```bash
flutter run
```

### 6. Build a release

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ipa --release
```

The app runs fine without a key — the chat feature simply reports that it isn't configured in Remote Config.

### 🔑 Secrets

| Secret | Where it lives | Committed? |
|---|---|---|
| `OLLAMA_API_KEY` | **Firebase Remote Config** | ❌ (Managed via Firebase Console) |
| Firebase configs | `google-services.json`, `firebase_options.dart` | ❌ (CI secrets `GOOGLE_SERVICES_JSON_BASE64`, `FIREBASE_OPTIONS_BASE64`) |
| Android keystore | `android/app/upload-keystore.jks`, `android/key.properties` | ❌ (CI secret `ANDROID_KEYSTORE_BASE64`) |

Never commit any of the above. CI restores file-based secrets from repository secrets at build time.

---

## 🧪 Testing

45 test suites cover data sources, repositories, use cases, cubits, and widgets, using `mockito` for doubles and `bloc_test` for state assertions.

```bash
flutter test                                  # everything
flutter test test/features/auth               # one feature
flutter test --coverage                       # with coverage report
```

Mocks are generated — regenerate them with `build_runner` after changing a mocked contract.

---

## 🔄 CI/CD

| Workflow | Trigger | What it does |
|---|---|---|
| `dart_lint.yml` | Push to `develop`, all PRs | `flutter analyze` + lint after restoring secrets and running codegen |
| `unit-tests.yml` | All PRs | Runs the full test suite |
| `validate-pr-title.yml` | All PRs | Enforces Conventional Commit PR titles |
| `validate_branch_name.yaml` | All PRs | Enforces `feature\|bugfix\|hotfix\|refactor/SF-<num>-<desc>` |
| `distribution.yml` | Push to `main` | Semantic version bump → build → Firebase App Distribution |
| `shorebird_patch.yml` | Manual | Pushes an OTA hotfix patch via Shorebird |

---

## 🤝 Contributing

### Branch naming

```
feature/SF-<ticket>-<short-description>
bugfix/SF-<ticket>-<short-description>
hotfix/SF-<ticket>-<short-description>
refactor/SF-<ticket>-<short-description>
```

`develop` is the integration branch and the default PR target. `main` is release-only.

### Commits & PR titles

[Conventional Commits](https://www.conventionalcommits.org/) — enforced by CI on PR titles, and used by `distribution.yml` to compute the next version:

```
feat(auth): add facebook sign-in         → minor bump
fix(chat): handle empty tool response    → patch bump
feat!: redesign onboarding flow          → major bump
```

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `build`, `ci`.

### Before you open a PR

```bash
dart format .
flutter analyze
flutter test
```

### Conventions

- Keep each feature inside its own `features/<name>/` slice with the four-layer structure above.
- Domain layer stays framework-free — no Dio, no Hive, no Flutter imports.
- New endpoints go in `AppEndPoints`, grouped by feature and prefixed with `baseUrl`.
- New routes go in `AppRoutes.onGenerateRoute` with a typed `Args` class for parameters.
- User-facing strings go in `AppStrings` with entries in **both** `assets/translations/en.json` and `ar.json`.
- Prefer composing small widgets over private `_buildX()` helper methods.

---

## 👥 Team

Built by **Elevate Team 6** — 329 commits and counting.

| Name | GitHub |
|---|---|
| Ahmed Emam | [@ahmedemam55](https://github.com/ahmedemam55) |
| Abanoub | [@abanoub6](https://github.com/abanoub6) |
| Abdelmalek Mokhtar | [@abdalmlk5](https://github.com/abdalmlk5) |
| Yousef Abdelghdar | [@yousefsinger](https://github.com/yousefsinger) |

---

<div align="center">

Made with ❤️ and Flutter

</div>
