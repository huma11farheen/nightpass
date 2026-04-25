# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (dev)
flutter run

# Lint / analyze
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Generate code (Freezed, json_serializable, Riverpod generators) — run after modifying models or annotated files
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during active development
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Architecture

The app uses **clean architecture** with feature-based folder organization inside `lib/`.

### Layers

| Layer | Location | Purpose |
|---|---|---|
| Models | `lib/data/supabase_models/` | Auto-generated Dart models from OpenAPI spec — do not edit manually |
| ViewModels | `lib/<feature>/<feature>_view_model.dart` | Freezed presentation models merging multiple Supabase models (e.g. `EventViewModel` = `Event` + `Club`) |
| Repositories | `lib/repository/` | All Supabase queries — single source of truth for data access |
| Data Providers | `lib/data/providers/` | `@Riverpod(keepAlive: true)` providers that instantiate repositories |
| Domain | `lib/domain/` | StateNotifiers and complex cross-feature logic |
| Presentation | `lib/<feature>/` | Feature screens with local StateNotifier + Freezed state |
| Widgets | `lib/widgets/` | Shared UI components |
| Utils | `lib/utils/` | Extensions, payment handler (`payment_handler.dart`), Supabase edge function calls (`supabase_functions.dart`) |

### State Management Patterns

Two patterns are used — pick based on complexity:

**Simple async data** (read-only, no user interaction): `@riverpod` function provider returning a `Future<T>`.

```dart
@Riverpod(keepAlive: true)
Future<List<EventViewModel>> getEvents(Ref ref) {
  return ref.watch(eventRepositoryProvider).fetchUpcomingEvents();
}
```

**Complex screen state** (user interactions, multi-step flows): `StateNotifier<T>` with a `@freezed` state class.

```dart
// state file
@freezed
abstract class BuyTicketState with _$BuyTicketState {
  const factory BuyTicketState({
    @Default(true) bool loading,
    @Default(0) int maleTicketCount,
    EventViewModel? event,
  }) = _BuyTicketState;

  const BuyTicketState._(); // required for computed properties

  double get totalPriceWithTax => /* ... */;
}

// notifier file
class BuyTicketNotifier extends StateNotifier<BuyTicketState> {
  BuyTicketNotifier(...) : super(const BuyTicketState());
}
```

- Screens extend `ConsumerWidget` or `ConsumerStatefulWidget`.
- `ref.watch()` for reactive state; `ref.read()` inside callbacks/handlers.
- `get_it` is used only for non-Riverpod services (e.g. `NotificationService`).

### Supabase Data Access

Repositories issue all queries directly against `supabase` (the singleton `SupabaseClient` from `lib/supabase/supabase_client.dart`). Joins are done inline using PostgREST select syntax:

```dart
supabase
  .from(Event.modelName) // static const on every model
  .select('*, ${Club.modelName}(*)')
  .gte('end_date', today)
  .order('start_date', ascending: true);
```

Results are mapped to ViewModels inside the repository. Raw Supabase model classes live in `lib/data/supabase_models/` and each exposes `static const modelName = "<table_name>"`.

### Routing

**GoRouter** (`lib/router.dart`) — key conventions:

- Route path constants live in a `Routes` abstract class in the same file.
- Typed data is passed between screens via `context.push(Routes.path, extra: data)` and cast from `state.extra`.
- Auth redirect guard (`_redirectIfSignedIn`) runs on every navigation — checks `supabase.auth.currentSession`.
- `CustomTransitionPage` with a pass-through `transitionsBuilder` is used to preserve Hero animations.

### Environment & Initialization

- `.env.dev` / `.env.prod` (not committed) are loaded via `flutter_dotenv`. Required keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `STRIPE_PUBLISHABLE_KEY`.
- `main()` initialization order: `Config.load()` → `configureSupabase()` → `Firebase.initializeApp()` → `NotificationService().initialize()` → `runApp(ProviderScope(...))`.
- Production vs dev is toggled by a compile-time `isProduction` constant in `lib/supabase/config.dart`.

### Code Generation

Generated files (`*.freezed.dart`, `*.g.dart`) are checked in. Re-run after modifying any class annotated with `@freezed`, `@JsonSerializable`, or `@riverpod`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Backend Services

- **Supabase** — PostgreSQL + auth + real-time subscriptions.
- **Firebase** — FCM push notifications. `firebaseMessagingBackgroundHandler` must be a top-level function. FCM token is saved to Supabase on login via `NotificationService().saveFCMToken()`.
- **Stripe** — `flutter_stripe`. Payment flow uses `PaymentHandler` in `lib/utils/payment_handler.dart`. Apple Pay / Google Pay setup: see `APPLE_PAY_GOOGLE_PAY_SETUP.md`.
- **Cloudinary** — Image upload/CDN for club and event images.
