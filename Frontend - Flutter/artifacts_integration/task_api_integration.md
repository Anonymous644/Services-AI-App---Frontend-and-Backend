# API Integration & Enhanced Actions Tasks

- `[x]` 1. **App Permissions**: Add location permissions to `AndroidManifest.xml` and iOS `Info.plist`.
- `[x]` 2. **Backend Booking Details**: Update `tool-executor.ts` and `ai.service.ts` to emit comprehensive booking details.
- `[x]` 3. **Backend Location Flow**: Add `request_location` tool, update `SYSTEM_PROMPT`, and handle `LOCATION_UPDATED` in `chat.gateway.ts`.
- `[x]` 4. **Backend Provider Distance**: Extract `distance` from `AIMemory` during `rank_providers` execution.
- `[x]` 5. **Frontend Action Widgets**: Build `LocationRequestCard`, `ProviderSelectionCard`, `PaymentRequestCard`, `CompletionCard`, and `ReviewCard`.
- `[x]` 6. **Frontend Integration**: Hook up the new action widgets to `ChatBubble` and ensure WebSocket events are emitted properly.
