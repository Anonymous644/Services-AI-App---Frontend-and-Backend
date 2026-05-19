# State Management & Architecture Plan

Before we start building the visual UI widgets, there are a few critical architectural layers missing that sit between the UI and the Repositories. Without these, the UI would be forced to handle complex logic. 

Here is the plan to finalize all core logic:

## User Review Required
Please review the proposed controllers and routing approach. Specifically, confirm if you are okay with adding the Google Maps packages now.

## Proposed Changes

### 1. Update Project Dependencies
We need to add the mapping packages for the UI layer since they involve native configurations.
- **[MODIFY]** `pubspec.yaml`: Add `google_maps_flutter` and `geolocator` (or `location`).

### 2. Socket Event Listeners (Chat)
Currently, the `ChatRepository` only *sends* messages. It needs to listen to the backend events.
- **[MODIFY]** `lib/features/chat/data/chat_repository.dart`
  - Add streams or callbacks to listen to: `chat_history`, `message_complete`, `stream`, `thinking`, `ai_thinking`, and `error`.

### 3. State Management (ViewModels / Controllers)
We need Riverpod Notifiers to hold the actual state that the UI will listen to.
- **[NEW]** `lib/features/auth/presentation/auth_controller.dart`: `AsyncNotifier<User?>` to hold the globally logged-in user state, load session on startup, and handle login/logout methods.
- **[NEW]** `lib/features/bookings/presentation/bookings_controller.dart`: `AsyncNotifier<List<Booking>>` to hold the list of bookings and handle status updates locally.
- **[NEW]** `lib/features/chat/presentation/chat_controller.dart`: `Notifier<List<ChatMessage>>` to manage the active chat array and UI typing indicators.

### 4. Native Routing Setup
Since we are using Flutter's built-in Navigator, we need a central place to define routes.
- **[NEW]** `lib/core/routing/app_router.dart`: Define static route strings (e.g., `/login`, `/customer_main`, `/provider_main`, `/chat`) and a global `onGenerateRoute` factory to handle role-based navigation.

## Verification Plan
1. Ensure all `dart run build_runner build` generation completes without errors for the new Riverpod controllers.
2. Confirm `flutter analyze` still passes with 0 issues.
