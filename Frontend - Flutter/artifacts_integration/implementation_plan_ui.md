# UI Implementation Plan

Based on the requirements, here is the complete architectural mapping for all visual screens, navigation logic, and specific features (like Voice Typing and AI Streaming) for the frontend app.

## User Review Required
Please review the screen definitions below. Specifically, confirm if adding `speech_to_text` (for voice typing), `flutter_animate` (for subtle chat animations), and `intl` (for dates) to our dependencies is approved.

## Open Questions
To ensure the UI is built exactly to your vision, please clarify the following points:

> [!IMPORTANT]
> 1. **Signup Location**: The backend requires a `Location` (address, city, and GPS coordinates) when a user signs up. Should we include a Google Map picker on the Signup screen for them to pin their location, or just use text fields for now?
> 2. **Profile Screen**: Besides the user's details, credit balance, and a Logout button, what other features do you want on the Profile tab? (e.g., an "Edit Profile" form or an "Active" toggle for Providers?)
> 3. **Voice Typing**: Should the microphone button in the chat be "Hold to Talk" (record while pressing) or "Tap to Start / Tap to Stop"?
> 4. **AI Interactive Actions**: When the AI proposes a booking or asks for payment, it sends an `actionType` (like `SELECT_PROVIDER` or `PAY`). Should these be rendered as clickable buttons directly inside the AI's chat bubble?

## Proposed Changes

### 1. New Dependencies
- **[MODIFY]** `pubspec.yaml`: Add `speech_to_text`, `flutter_animate`, and `intl`.

### 2. Screens Architecture

#### Splash Screen (`lib/features/splash/splash_screen.dart`)
- **Functionality**: Intercepts app launch, checks the `AuthController` state.
- **Navigation**: If session exists -> Route to Customer/Provider Main based on `UserRole`. If null -> `LoginScreen`.

#### Auth Screen (`lib/features/auth/presentation/auth_screen.dart`)
- **Functionality**: Clean, modern email/password form handling both Login and Signup. Includes loading overlays and toast triggers.

#### Customer Main Screen (`lib/features/customer/presentation/customer_main_screen.dart`)
- **Layout**: Main Scaffold with a `BottomNavigationBar` (3 tabs) managed by a local state (IndexedStack).
- **Tabs**:
  1. **BookingsView (Default)**: Displays historical/active bookings. Contains horizontal scrollable filter chips (All, Pending, Completed, Cancelled). Includes a prominent "Start New Booking" button that dynamically switches the bottom nav index to the Chat tab.
  2. **ChatView**: The AI Service interface.
  3. **ProfileView**: Shows credit balance and user details.

#### Provider Main Screen (`lib/features/provider/presentation/provider_main_screen.dart`)
- **Layout**: Scaffold with `BottomNavigationBar` (2 tabs).
- **Tabs**:
  1. **BookingsView (Default)**: Similar to customer, but scoped to provider's assigned jobs.
  2. **ProfileView**: Provider stats, rating, and settings.

#### Booking Details Screen (`lib/features/bookings/presentation/booking_details_screen.dart`)
- **Functionality**: A reusable standalone screen pushed via `Navigator.pushNamed`. Displays all details (map snippet, timeline, prices).
- **Role-Based Logic**:
  - **Provider**: Displays dynamic action buttons to update status (e.g., "Initialize Job", "Mark Completed") using `BookingsController`.
  - **Customer**: Displays "Pay" or "Review" actions depending on the booking lifecycle.

#### Advanced Chat Screen UI (`lib/features/chat/presentation/chat_view.dart`)
- **Message List**: `ListView.builder` for historical `ChatMessage` objects mapped from `ChatController`.
- **AI Streaming Bubble**:
  - Bound directly to `ChatState.isAiThinking`.
  - If `streamingContent` is empty, shows the internal process (`thinkingMessage` like "Finding providers...").
  - As `streamingContent` populates, it types out the message dynamically.
- **Voice-Enabled Input**: A sticky bottom input bar. Contains a `TextField` and a Microphone icon. Pressing the mic activates `speech_to_text`, listening to the user and injecting the transcribed text directly into the input.
- **Animations**: `flutter_animate` will be used to slide and fade in new messages to create a modern, fluid UX.

### 3. Core Components (`lib/core/widgets/`)
- `BookingCard`: An elevated, sleek card for list views.
- `ChatBubble`: Tailored visual containers distinguishing USER (blue) vs ASSISTANT (white/gray).
- `StatusBadge`: Colored rounded pills indicating the booking's status.

## Verification Plan
1. Ensure the `speech_to_text` package requests OS microphone permissions correctly.
2. Verify role-based routing (Customer vs. Provider) successfully initializes the correct Main Screen.
3. Validate the Chat UI smoothly streams the AI response without stuttering.
