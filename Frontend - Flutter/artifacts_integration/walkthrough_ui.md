# UI Implementation Walkthrough

The UI implementation phase is complete! The Flutter app now has a fully fleshed-out interface with role-based navigation and advanced feature integration.

> [!TIP]
> The app is built completely reactively. Riverpod state controllers and `flutter_animate` power all visual changes smoothly, from AI typing indicators to dynamic status badges.

## Components Built

### 1. **Core Widgets**
- **`BookingCard`**: A flexible list item showing the service category, location, scheduled date, and real-time total price.
- **`StatusBadge`**: Uses the backend's `BookingStatus` enum to display pill-shaped, color-coded badges (e.g., Orange for `PENDING`, Green for `COMPLETED`).
- **`ChatBubble`**: Handles markdown text, system prompts, and dynamically parsed `actions` payload to render clickable buttons (e.g., "Pay Now", "Select Provider").

### 2. **Authentication Flow**
- **Splash Screen**: Uses `authControllerProvider` to check session state on launch and safely redirect the user.
- **Login Screen**: Uses `TextFormField` validation.
- **Signup Screen**: Integrated with `geolocator` and `google_maps_flutter` for the requested Map Location Picker. Users can pin their address visually.

### 3. **Role-Based Workspaces**
- **Customer Main**: Features a tabbed layout containing `BookingsView`, `ChatView`, and `ProfileView`. The FAB on the Bookings view intelligently navigates the user straight to the AI Chat.
- **Provider Main**: Focused view containing only `BookingsView` and `ProfileView`, with an "Active Status" toggle switch built into their profile.
- **Bookings View**: Both user types get quick-filter horizontal chips (`All`, `Pending`, `Active`, `Completed`) to sort through their active lists.

### 4. **Chat Interface**
- **Speech-to-Text**: Added Voice Typing functionality. Tapping the mic button toggles `speech_to_text`, listening to the user, and auto-submitting the prompt.
- **Real-time AI Feedback**: A custom `ThinkingBubble` is displayed while waiting for the AI. When streaming starts, the `ChatBubble` dynamically replaces the thinking indicator.
- **Action Buttons**: The UI safely parses JSON actions inside AI responses and creates `ElevatedButton`s to send `action_response` events back down the WebSocket.

### 5. **Booking Details**
- Dynamically handles button rendering based on the user's role and the booking's exact status.
  - Providers see **"Initialize Job"** and **"Mark Completed"**.
  - Customers see **"Proceed to Pay"** and **"Leave a Review"**.

> [!WARNING]
> Because `google_maps_flutter` is installed, you must add a valid Google Maps API Key to `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift` for the Map Picker to render fully, otherwise the screen may render blank on the map section.

## Next Steps

1. Supply API Keys for Google Maps.
2. Bind the UI to actual backend endpoints.
3. Test locally using the emulator.
