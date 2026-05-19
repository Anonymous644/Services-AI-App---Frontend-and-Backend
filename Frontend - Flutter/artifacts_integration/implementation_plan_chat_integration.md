# Plan: Fix Chat Socket Event Handling & Action UI

## TL;DR
7 bugs across two areas: (1) duplicate messages from backend USER echo + premature thinking hide; (2) all 5 action types send the wrong payload/action code to the backend. Fixes: filter USER echo in controller + rebuild all action UI widgets to match backend protocol exactly.

---

## Root Cause Analysis

### Bug Group 1 — Duplicate Messages & Thinking Flash
Backend emits `message_complete` TWICE per user message:
1. `{role: 'USER'}` — echoes the user's own message back
2. `{role: 'ASSISTANT'}` — the final AI response

`_completeSub` processes BOTH. The USER echo causes:
- A second identical user bubble (duplicate)
- `isAiThinking: false` set prematurely → thinking indicator disappears → "previous AI response shown"

### Bug Group 2 — Action Button Payloads
Display types (what AI sends) ≠ response types (what backend expects back).  
All buttons currently call `sendActionResponse(displayType, rawData)` → hits `default: JSON.stringify(data)` → sends massive JSON to AI.

---

## Event Sequence (verified from source)
```
User sends → socket emit('send_message')
  1. emit message_complete {role:'USER'}   ← SKIP in Flutter
  2. emitThinking() × N → socket emit('thinking')
  3. emitStream() × N → socket emit('stream')
  4. emit message_complete {role:'ASSISTANT'}  ← PROCESS this
```
Note: `ai_thinking` socket event is NEVER emitted by backend — `_aiThinkingSub` is dead code.

---

## Action Protocol (backend contract)

| Display type (AI sends) | Response type (client sends) | Required payload |
|---|---|---|
| `PROVIDER_SELECTION` | `SELECT_PROVIDER` | `{ providerId: string }` |
| `PAYMENT_REQUEST` | `PAY` | `{ bookingId: string }` |
| `BOOKING_CARD` | — (info only, no action) | — |
| `CONFIRM_COMPLETION` | `CONFIRM_COMPLETION` | `{ confirmed: bool, bookingId, reason? }` |
| `REVIEW_REQUEST` | `SUBMIT_REVIEW` | `{ rating: 1-5, comment?: string }` |

### Action data shapes
- `PROVIDER_SELECTION.data`: `{ categoryName, overallReasoning, providers: [{rank, providerId, name, rating, totalJobs, experience, bio, reasoning, estimatedPrice, isTopPick}] }`
- `PAYMENT_REQUEST.data`: `{ bookingId, amount, customerCredits, canPayWithCredits }`
- `BOOKING_CARD.data`: `{ bookingId, status, categoryName?, subCategoryName?, providerName, scheduledAt?, totalAmount? }`
- `CONFIRM_COMPLETION.data`: `{ bookingId, providerName, serviceDetails }`
- `REVIEW_REQUEST.data`: `{ bookingId, providerName }`

---

## Steps

### Phase 1 — Fix Duplicate Messages
**`chat_controller.dart`**
- `_completeSub`: add `if (message.role == ChatMessageRole.user) return;`
- Remove `_aiThinkingSub` field + subscription (dead code — event never fires)

### Phase 2 — New Action Widgets
**New file**: `lib/features/chat/presentation/chat_actions.dart`

- **`ProviderSelectionAction`**: "View Providers" button → `showModalBottomSheet` with ranked cards (rank badge, name, rating, experience, price, reasoning) → "Select" → `onActionPressed('SELECT_PROVIDER', { 'providerId': id })`
- **`PaymentRequestAction`**: Inline card (amount, credits info) + "Pay Now" button → confirm dialog → `onActionPressed('PAY', { 'bookingId': id })`
- **`BookingInfoCard`**: Read-only card (status chip, provider, category, date, amount). No action.
- **`ConfirmCompletionAction`**: Two buttons — "Confirm ✓" → `('CONFIRM_COMPLETION', {confirmed:true, bookingId})` and "Dispute ✗" → reason dialog → `('CONFIRM_COMPLETION', {confirmed:false, bookingId, reason})`
- **`ReviewRequestAction`**: "Leave a Review" → dialog with 5-star tap selector + comment field → `('SUBMIT_REVIEW', {rating, comment?})`

### Phase 3 — Update ChatBubble
**`lib/core/widgets/chat_bubble.dart`**
- Replace `_buildActions` to dispatch per action type using Phase 2 widgets
- Action widgets call `onActionPressed` with backend-ready payload (translated)
- Remove old generic `FilledButton.tonal` + `_formatActionName`

---

## Relevant Files
- `lib/features/chat/presentation/chat_controller.dart`
- `lib/core/widgets/chat_bubble.dart`
- `lib/features/chat/presentation/chat_actions.dart` (NEW)

## Verification
1. Send message → only ONE user bubble, thinking indicator stays visible continuously
2. View Providers → bottom sheet with 3 cards → Select → AI confirms booking
3. Pay card → confirm dialog → payment confirmed
4. Confirm Completion / Dispute → correct AI response
5. Leave a Review → star rating dialog → AI thanks
6. BOOKING_CARD is read-only (no tap)

## Decisions
- `BOOKING_CARD` info-only (no send) to avoid JSON being sent to AI
- `_aiThinkingSub` removed (backend never emits `ai_thinking`)
- Provider selection uses bottom sheet for space; payment uses inline card for context
