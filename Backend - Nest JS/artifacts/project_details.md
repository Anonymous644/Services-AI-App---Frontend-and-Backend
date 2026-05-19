# Services AI App — Project Details

## Overview

**Services AI** is a SaaS mobile-first platform that connects **Customers** who need home/professional services with **Providers** who fulfill those services. The entire booking lifecycle — from service discovery to provider matching to completion confirmation — is orchestrated by an **AI conversational agent** running on the backend, communicating via **real-time WebSocket streaming**.

---

## Tech Stack

| Layer           | Technology                                                      |
| --------------- | --------------------------------------------------------------- |
| Runtime         | Node.js                                                         |
| Framework       | NestJS (v10)                                                    |
| Database        | MongoDB (Atlas) with Atlas Vector Search                        |
| ORM             | Prisma (v6) with MongoDB provider                               |
| AI Chat         | Google Gemini 3.0 Flash (with thinking mode)                    |
| AI Embeddings   | Gemini Embedding (`gemini-embedding-001`, 768 dims)             |
| AI SDK          | `@google/generative-ai`                                         |
| Real-time       | Socket.IO (`@nestjs/websockets` + `@nestjs/platform-socket.io`) |
| Auth            | JWT (30-day expiry) + Passport                                  |
| API Docs        | Swagger / OpenAPI                                               |
| Package Manager | Yarn                                                            |

---

## Architecture

| Module           | Components                                                                                                                                                     |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AuthModule`     | AuthService, JwtStrategy, JwtAuthGuard (global), RolesGuard (global)                                                                                           |
| `BookingsModule` | ChatGateway (WebSocket), AIService, BookingService, ChatService, TransactionService, ProviderSearchService, ReviewService, NotificationService, DisputeService |

### Communication Channels

- **Customer ↔ AI**: WebSocket (Socket.IO) with streaming
- **Provider ↔ Backend**: REST API
- **Provider action → Customer notification**: REST triggers WebSocket push to customer

### Auth Decorators & Guards

| Decorator/Guard             | Purpose                                                         |
| --------------------------- | --------------------------------------------------------------- |
| `@Public()`                 | Skip JWT auth on specific routes (signup, login)                |
| `@Roles(UserRole.CUSTOMER)` | Restrict route to specific user roles (RBAC)                    |
| `@GetUser()`                | Extract JWT payload from request (`@GetUser('sub')` for userId) |
| `JwtAuthGuard`              | Global guard — all routes require JWT by default                |
| `RolesGuard`                | Global guard — checks `@Roles()` metadata on routes             |

### Auth Endpoints

| Endpoint           | Method | Auth   | Description                     |
| ------------------ | ------ | ------ | ------------------------------- |
| `/api/auth/signup` | POST   | Public | Register (Customer or Provider) |
| `/api/auth/login`  | POST   | Public | Login, returns JWT + user       |
| `/api/auth/me`     | GET    | JWT    | Get current user profile        |

### Booking REST Endpoints

| Endpoint                   | Method | Auth     | Description                                                |
| -------------------------- | ------ | -------- | ---------------------------------------------------------- |
| `/api/bookings`            | GET    | JWT      | List bookings (role-filtered)                              |
| `/api/bookings/:id`        | GET    | JWT      | Single booking details                                     |
| `/api/bookings/:id/status` | PATCH  | Provider | Update status (INITIALIZED, PROVIDER_COMPLETED, CANCELLED) |
| `/api/bookings/:id/pay`    | POST   | Customer | Process mock payment                                       |
| `/api/bookings/:id/review` | POST   | JWT      | Submit a review                                            |

---

## User Roles

A user can only be a **Customer** or a **Provider** — never both. Role is set at registration and cannot change.

### 1. Customer

- Logs in via a mobile app.
- Interacts with an **AI Chat Agent** via WebSocket (real-time streaming).
- Receives AI-recommended providers with reasoning and thinking display.
- Selects a provider and completes (mock) payment via action buttons in chat.
- Confirms job completion or raises a dispute when prompted by AI.
- Reviews the provider after a completed booking (via AI chat).

### 2. Provider

- Logs in via the same mobile app (role-based view).
- Sees incoming bookings on a dashboard via REST API.
- Updates booking status: **Initialized → Completed / Cancelled**.
- Status updates trigger real-time AI messages to the customer via WebSocket.
- Receives payment (minus 5% platform fee) upon customer-confirmed completion.
- Reviews the customer after a completed booking (via booking details screen).
- Has a **service radius** (max distance in km willing to travel).
- Has weekly **availability** slots (day of week + time ranges).

### Registration Requirements

- **Both roles**: email, password, firstName, lastName, location (with GeoJSON coordinates)
- **Optional**: phone number, avatar
- **Provider-specific**: bio, experience, serviceRadius, availability (can be set after registration)

---

## Real-time Communication (WebSocket)

### Socket.IO with JWT Authentication

Customer connects to Socket.IO at `/chat` namespace. Token accepted from **3 sources**:

1. **Handshake auth**: `{ token: "Bearer xxx" }`
2. **Authorization header**: `Authorization: Bearer xxx` (easiest for Postman)
3. **Query param**: `/chat?token=xxx`

### Client → Server Events

| Event             | Payload                             | Description                                                            |
| ----------------- | ----------------------------------- | ---------------------------------------------------------------------- |
| `send_message`    | `{ content: string }`               | Customer sends a chat message                                          |
| `action_response` | `{ actionType: string, data: any }` | Customer responds to an action (select provider, pay, confirm, review) |

### Server → Client Events

| Event              | Persisted?  | Description                                                     |
| ------------------ | ----------- | --------------------------------------------------------------- |
| `thinking`         | ❌          | Backend status: "Searching services...", "Finding providers..." |
| `ai_thinking`      | ❌          | Gemini's chain-of-thought reasoning (streamed live)             |
| `stream`           | ❌ (chunks) | AI response text chunks as they generate                        |
| `message_complete` | ✅          | Final message with full text + actions → saved to ChatMessage   |
| `error`            | ❌          | Error notification                                              |

### Message Structure (persisted)

```json
{
  "id": "...",
  "role": "ASSISTANT",
  "content": "I found 3 great providers for your AC repair...",
  "actions": [
    {
      "type": "PROVIDER_SELECTION",
      "data": {
        "categoryName": "AC Services",
        "overallReasoning": "I prioritized proximity and rating...",
        "providers": [
          {
            "rank": 1,
            "providerId": "abc123",
            "name": "Ahmed Khan",
            "rating": 4.8,
            "experience": 8,
            "reasoning": "Best match: closest (0.7km), highest rated, available at your time",
            "estimatedPrice": 2800,
            "isTopPick": true
          }
        ]
      }
    }
  ]
}
```

### Action Types

| Type                 | When Used                                     | Data Payload                                                                                                     |
| -------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `PROVIDER_SELECTION` | Top 3 providers with select buttons           | `{ categoryName, overallReasoning, providers[] }`                                                                |
| `PAYMENT_REQUEST`    | Pay button with amount and booking ID         | `{ bookingId, totalAmount }`                                                                                     |
| `BOOKING_CARD`       | Booking details summary (read-only)           | `{ bookingId, status, categoryName, subCategoryName, providerName, scheduledAt, totalAmount, paidAt, location }` |
| `LOCATION_REQUEST`   | Map picker to confirm/update booking location | `{ currentAddress, currentCity, currentLatitude, currentLongitude }`                                             |
| `CONFIRM_COMPLETION` | Yes/No buttons for job completion             | `{ bookingId, providerName }`                                                                                    |
| `REVIEW_REQUEST`     | Rating stars + comment input                  | `{ bookingId, providerName }`                                                                                    |

---

## Location & Geospatial

All locations (User, Booking) use **GeoJSON format** for MongoDB geospatial queries:

- `coordinates: [longitude, latitude]`
- MongoDB `2dsphere` indexes on `users.location.geo` and `bookings.location.geo`
- Provider search uses `$geoNear` aggregation within **30km radius** of booking location

### Location Confirmation Flow (Customer)

1. AI calls `request_location` tool during booking info gathering
2. Backend sends `LOCATION_REQUEST` action with the customer's current registered coordinates (`currentLatitude`, `currentLongitude`, `currentAddress`, `currentCity`)
3. Flutter shows a card with a **"Confirm on Map"** button
4. Tapping opens a full-screen bottom sheet (88% screen height) with Google Maps
5. Map auto-centers on GPS position first, falls back to registered coordinates
6. Customer taps to move the pin; reverse geocoding auto-fills address/city/state
7. On confirm → `action_response` with `LOCATION_UPDATED` → backend updates `user.location` in DB → sends message to AI to proceed

### `request_location` Tool

- No input parameters — just triggers the map UI
- AI calls it when it needs the customer to confirm/update their booking location
- AI should NOT ask for location details in text when calling this tool

---

## Vector Search (Service Discovery)

Service categories are **flat** (no hierarchy). AI infers subcategory names from context.

- **Model**: `gemini-embedding-001` with `output_dimensionality: 768`
- **Embedding text**: `"{category.name}: {category.description}"`
- **Index**: `service_category_vector_index` on `embedding` field (cosine similarity)
- **Runtime**: User query → embed → `$vectorSearch` → top matching category
- **Fallback**: If vector search fails or returns empty (no index/embeddings), falls back to **text-based matching** on category name + description with word-level scoring
- **Subcategory**: AI infers subcategory name (e.g., "AC Repair") and stores it as `subCategoryName` on Booking (text only, not a DB entity)

```
User: "my AC is leaking water"
  → Embed query (768 dims)
  → $vectorSearch on service_categories
  → Result: "AC Services" (score: 0.94)
  → [If vector fails] → text fallback: "AC" matches "AC Services" (score: 1.3)
  → AI infers subcategory: "Repair"
```

---

## Core App Flow

### A. Booking Creation (Customer Side — via WebSocket)

1. Customer sends a message via WebSocket describing their need.
2. AI detects booking intent and starts gathering details (always asked fresh — never assumed from previous bookings):
   - **Service** — AI uses vector search to find the matching category
   - **Subcategory** — AI infers from context (e.g., "AC Repair")
   - **Service Details** — specifics gathered conversationally
   - **Preferred Date & Time** — always re-asked for each new booking
   - **Location** — AI calls `request_location` tool; customer confirms/updates via map picker
   - **Notes** — any additional notes (optional)
3. AI creates a **dedicated AIMemory record** (step: `GATHERING_INFO`).
4. Whenever details are missing, AI asks the customer.
5. Once all details are gathered, AI searches for providers (step: `SEARCHING_PROVIDERS`).

> **Memory Reset Rule**: If a customer starts searching for a new service after a booking is already `BOOKING_CREATED` / `COMPLETED` / etc., the old AIMemory is deactivated and a fresh one is created. The AI must re-ask date, time, location, and notes — never carry them over from the previous booking.

### B. Provider Search & Selection

1. **Provider search** (backend, 30km radius):
   - `$geoNear` aggregation: providers within 30km of booking location
   - Filter: provider has a `ProviderService` matching the found category
   - Sort: by provider rating (descending)
   - Limit: **10 providers**

2. **AI ranking** (Gemini compares the 10):
   - AI receives all 10 providers with their details (ratings, totalJobs, distance, availability slots, min/max prices)
   - AI compares against the user's requested time, service complexity, distance
   - AI determines a **per-provider price** (factoring in complexity, provider's min/max range, and distance)
   - AI selects **top 3** with reasoning
   - AI's thinking process is streamed to the customer as `ai_thinking` events

3. **Provider presentation** (step: `AWAITING_SELECTION`):
   - AI sends a message with a `PROVIDER_SELECTION` action
   - Each provider card shows: name, rating, totalJobs, distance, price, reasoning
   - Customer selects one

### C. Booking Creation & Payment

1. On provider selection → AI calls `create_booking` tool
2. Booking created with status `UNPAID` (step: `AWAITING_PAYMENT`)
3. AI sends a `PAYMENT_REQUEST` action with booking ID and amount
4. Customer taps "Pay" → `action_response` with `PAY` type
5. Backend creates mock Transaction, updates booking to `PENDING`
6. AI sends confirmation: "Payment confirmed! Your booking is confirmed for [date/time]..."
7. AI sends a `BOOKING_CARD` action with full booking details
8. Provider receives a notification about the new booking
9. AIMemory step moves to `BOOKING_CREATED`

### D. Provider Workflow (REST API)

1. Provider sees the booking on their app → `GET /api/bookings`
2. Provider marks `INITIALIZED` → `PATCH /api/bookings/:id/status`
   - `initializedAt` timestamp recorded
   - Backend generates AI response for customer's chat
   - WebSocket pushes to customer in real-time: "Your provider has started working on your AC Repair!"
3. Provider marks `PROVIDER_COMPLETED` → `PATCH /api/bookings/:id/status`
   - Backend generates AI response asking customer to confirm
   - WebSocket pushes to customer with `CONFIRM_COMPLETION` action

### E. Job Confirmation (Customer Side — AI-driven)

When the provider marks `PROVIDER_COMPLETED`, the AI asks the customer to confirm (step: `AWAITING_COMPLETION`):

1. **Customer confirms** (says yes, or taps "Confirm" button):
   - AI calls `confirm_completion` tool
   - Booking status → `COMPLETED`, `completedAt` set
   - Provider receives 95% payout → `PROVIDER_PAYOUT` transaction, credits added
   - Platform retains 5% → `PLATFORM_FEE` transaction
   - AI proceeds to review collection

2. **Customer disputes** (says no, or explains the provider didn't complete the job):
   - AI calls `create_dispute` tool with the customer's reason
   - Booking status → `DISPUTED`, `disputedAt` set
   - Dispute record created with customer's description
   - Payment transaction set to `ON_HOLD`
   - AI tells customer: "Your booking has been put into dispute. Our customer support will contact you to resolve the issue."
   - Provider receives a dispute notification

### F. Review Collection

1. After booking completion, AI asks the customer to review (step: `AWAITING_REVIEW`)
2. AI sends a `REVIEW_REQUEST` action (rating + comment)
3. Customer provides rating (1–5) and optional comment
4. AI calls `submit_review` tool
5. Provider's average rating is recalculated
6. AIMemory step → `COMPLETED`, `isActive` = false
7. Provider reviews the customer separately via `POST /api/bookings/:id/review`

### G. Cancellation

- **Customer** can cancel before INITIALIZED (status is `PENDING`)
- **Provider** can cancel at any point (PENDING or INITIALIZED)
- On cancellation:
  - Booking status → `CANCELLED`, `cancelledBy` recorded
  - Payment refunded to customer's credit balance
  - `REFUND` transaction created
  - If provider cancels → AI message pushed to customer via WebSocket

---

## AI Agent Specifications

### AI Tools (Function Calling)

| #   | Tool                 | Purpose                                                 | Input                                                  | Output                                                                                                           |
| --- | -------------------- | ------------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| 1   | `search_services`    | Vector/text search → top matching category              | `{ query }`                                            | `{ services[], message }`                                                                                        |
| 2   | `search_providers`   | Geo query (30km) + category filter → 10 providers       | `{ categoryId, lng, lat }`                             | `{ providers[], count }`                                                                                         |
| 3   | `rank_providers`     | AI selects top 3 from 10 with reasoning + pricing       | `{ topPick, secondPick, thirdPick, overallReasoning }` | `{ rankedProviders[], overallReasoning }`                                                                        |
| 4   | `create_booking`     | Creates Booking (UNPAID) + updates AIMemory             | `{ providerId, categoryId, ... }`                      | `{ bookingId, status, totalAmount }`                                                                             |
| 5   | `process_payment`    | Mock transaction, booking → PENDING                     | `{ bookingId }`                                        | `{ bookingId, status, providerName, categoryName, subCategoryName, scheduledAt, totalAmount, location, paidAt }` |
| 6   | `confirm_completion` | Booking → COMPLETED, payout (95/5 split)                | `{ bookingId }`                                        | `{ bookingId, providerPayout }`                                                                                  |
| 7   | `create_dispute`     | Booking → DISPUTED, freezes payment                     | `{ bookingId, reason }`                                | `{ disputeId }`                                                                                                  |
| 8   | `find_booking`       | Search customer's bookings                              | `{ bookingId?, status? }`                              | `{ bookings[] }` (each includes `location`)                                                                      |
| 9   | `submit_review`      | Creates Review, recalculates rating                     | `{ bookingId, rating, comment? }`                      | `{ reviewId }`                                                                                                   |
| 10  | `request_location`   | Triggers map UI for customer to confirm/update location | _(no params)_                                          | _(triggers `LOCATION_REQUEST` action)_                                                                           |

### `rank_providers` — How It Works

`rank_providers` is a **write-back tool**: the AI doesn't call a function that ranks for it. Instead:

1. `search_providers` returns all 10 providers to Gemini
2. Gemini analyzes all 10 (rating, distance, experience, availability, pricing)
3. Gemini calls `rank_providers` passing its top 3 selections as structured arguments
4. Each pick includes: `providerId`, `reasoning` (detailed text), `estimatedPrice` (AI-determined)
5. The tool handler enriches picks with full DB data and builds the `PROVIDER_SELECTION` action

This means ranking, reasoning, and pricing happen **inside Gemini in a single API call**.

### AI Memory Steps

```
GATHERING_INFO → SEARCHING_PROVIDERS → AWAITING_SELECTION → AWAITING_PAYMENT
→ BOOKING_CREATED → AWAITING_COMPLETION → AWAITING_REVIEW → COMPLETED
```

### Tool Call Safety

- Max **10 tool iterations** per message (prevents infinite loops on rate limit errors)
- `result.functionCalls()` safely handled with optional chaining
- `result.text()` wrapped in try-catch (throws when response has only tool calls)

### AI Response Formatting

- AI responses are **plain text only** — no markdown, no bold, no bullets
- System prompt explicitly forbids formatting: `NEVER use markdown formatting`

### Streaming & Thinking Display

The AI streams its responses and thinking in real-time:

```
[thinking: "Understanding your request..."]           ← backend status
[thinking: "Searching for matching services..."]      ← backend status
[thinking: "Finding providers within 30km..."]        ← backend status
[thinking: "Analyzing and ranking providers..."]      ← backend status
[stream: "Great news! I found 3 excellent..."]         ← response text
[message_complete + PROVIDER_SELECTION action]          ← final message
```

### Message Roles

| Role        | Purpose                                                       |
| ----------- | ------------------------------------------------------------- |
| `USER`      | Customer's messages                                           |
| `ASSISTANT` | AI agent's conversational responses                           |
| `SYSTEM`    | Automated status messages (provider started, cancelled, etc.) |

### Chat Architecture

- **Single persistent chat** per customer
- Messages persisted with `content` (text) + `actions` (JSON array of UI elements)
- Tool calls and results stored on messages for context reconstruction
- Chat history loaded on WebSocket connect to restore context
- AI uses `AIMemory` for current booking flow state
- For previous bookings, AI uses `find_booking` tool

### AI Context Building

- **Pre-payment steps** (`GATHERING_INFO`, `SEARCHING_PROVIDERS`, `AWAITING_SELECTION`, `AWAITING_PAYMENT`): full context passed — date, time, location, gathered service details, provider list
- **Post-payment steps** (`BOOKING_CREATED` and beyond): only `bookingId` passed with a warning that booking is already confirmed — prevents AI from re-asking details or creating duplicate bookings

### Action Response → Chat Bubble

When a customer responds to an action widget, a user-side chat bubble is added optimistically before the AI reply:
| Action Type | User Bubble Text |
|---|---|
| `LOCATION_UPDATED` | `My location: {address}, {city}` |
| `SELECT_PROVIDER` | `I'd like to select this provider for my booking.` |
| `PAY` | `Please proceed with the payment.` |
| `CONFIRM_COMPLETION` (yes) | `Yes, the job was completed successfully.` |
| `CONFIRM_COMPLETION` (no) | `I want to dispute this — {reason}` |
| `SUBMIT_REVIEW` | `⭐⭐⭐⭐⭐ {comment}` |

---

## Payment & Credits System (Mock)

| Event                                 | Effect                                                      |
| ------------------------------------- | ----------------------------------------------------------- |
| Customer pays for booking             | Mock transaction (customer → platform); booking → `PENDING` |
| Booking completed (customer confirms) | Provider receives 95% → credits                             |
| Booking completed                     | Platform retains 5% (PLATFORM_FEE)                          |
| Customer cancels (before INITIALIZED) | Full refund to customer credits                             |
| Provider cancels (any time)           | Full refund to customer credits                             |
| Dispute raised                        | Provider payment frozen (ON_HOLD)                           |
| Customer uses credits                 | Only if credits cover the **full** booking amount           |

### Pricing

- AI determines per-provider pricing based on: service complexity, provider's minPrice/maxPrice range, and distance from booking location
- Different providers get different prices in the comparison
- The selected provider's price becomes the booking's `totalAmount`

### Transaction Parties

- `fromUserId = null` → money comes from the platform
- `toUserId = null` → money goes to the platform

---

## Booking Status Lifecycle

```
UNPAID → PENDING → INITIALIZED → PROVIDER_COMPLETED → COMPLETED
                 ↘                                   ↘ DISPUTED
                  CANCELLED (by customer or provider)
```

- `PROVIDER_COMPLETED` does NOT mean the booking is done — customer must confirm via AI
- `COMPLETED` is only set after customer confirms through the AI chat
- `DISPUTED` is set when customer tells the AI the job wasn't actually completed

---

## Notification Triggers

| Event                        | Recipient | Channel   | Notification                                   |
| ---------------------------- | --------- | --------- | ---------------------------------------------- |
| Booking paid (PENDING)       | Provider  | REST/DB   | "You have a new booking"                       |
| Provider initializes         | Customer  | WebSocket | AI message + BOOKING_CARD                      |
| Provider marks completed     | Customer  | WebSocket | AI asks to confirm + CONFIRM_COMPLETION action |
| Customer confirms completion | Provider  | REST/DB   | "Booking completed, payment received"          |
| Customer disputes            | Provider  | REST/DB   | "A dispute has been raised for booking X"      |
| Customer cancels             | Provider  | REST/DB   | "Booking X has been cancelled"                 |
| Provider cancels             | Customer  | WebSocket | AI message + notification                      |

---

## Key Business Rules

1. A user can only be a Customer OR a Provider, never both.
2. Service categories are flat — AI infers subcategory names from context.
3. Provider search uses a fixed **30km radius** from booking location. AI factors in actual distance when ranking.
4. AI determines **per-provider pricing** based on service complexity, provider price range, and distance.
5. The provider marking `PROVIDER_COMPLETED` does NOT complete the booking — **customer must confirm via AI**.
6. If the customer says the job wasn't completed → AI creates a dispute automatically.
7. A booking can be cancelled by the customer before INITIALIZED, or by the provider at any point.
8. The provider's payment is only released after the customer confirms completion.
9. The platform retains a flat 5% fee on all completed bookings.
10. Credits can only be used if they cover the full booking cost.
11. Both customer and provider can review each other (one review per party per booking).
12. AI maintains a single chat per customer with full history awareness.
13. Disputes freeze provider payment until manual resolution.
14. Services and providers are seeded on app init (if database is empty).

---

## Data Seeding

On `AppModule.onModuleInit()`, the app checks if the database has services:

- If no services exist → seed **12 service categories** (flat)
- **Generate 768-dim vector embeddings** for each category using Gemini Embedding API
- Seed **30 provider users** with profiles, services, and locations around Islamabad (near 33.714178, 73.071544)
- **8 unique availability presets**: fullTime, earlyBird, lateShift, weekdaysOnly, fullWeek, morningOnly, extendedHours, splitShift
- Providers cover all 12 categories with varied experience (3–15 yrs), ratings (4.2–4.9), job counts (40–300)
- Seeded password for all providers: `provider123`

**Manual step**: Create `service_category_vector_index` in MongoDB Atlas UI before vector search works.

---

## Flutter App — Key Implementation Details

### Speech Recognition

- Package: `speech_to_text: ^7.3.0`
- Required manifest permissions: `RECORD_AUDIO`, `INTERNET`
- Required `<queries>` entry: `android.speech.RecognitionService`
- Initialized in `initState` via `_speechToText.initialize()`; mic button shown in chat input bar
- On confirm → recognized text placed in the message text field

### Location Picker (`_LocationPickerSheet`)

- Full-screen bottom sheet (88% height) with `google_maps_flutter`
- Initializes map at GPS position → falls back to registered coordinates → falls back to Lahore default
- Tap anywhere on map to move the pin
- On "Confirm Location": `geocoding.placemarkFromCoordinates` → auto-fills address, city, state
- Sends `{ location: { address, city, state, coordinates: [lng, lat] } }` via `LOCATION_UPDATED` action

### BOOKING_CARD Widget

Displays (in order): category + subcategory header, status badge, provider name, scheduled date/time, location address+city, total amount, paid-at timestamp.

---

## MVP Scope

This is an MVP build. The following are **in scope**:

- ✅ Auth (JWT-based login/register for both roles)
- ✅ Real-time WebSocket chat (Socket.IO) with AI streaming + thinking display
- ✅ AI Chat Agent with memory, context, step tracking, and tool calling
- ✅ Vector search for service discovery (Gemini Embedding + Atlas Vector Search)
- ✅ Service category management (flat, seeded with embeddings)
- ✅ Provider geospatial search (30km radius + rating sort)
- ✅ AI-powered provider ranking with per-provider pricing and reasoning
- ✅ Full booking lifecycle (create → pay → initialize → confirm/dispute → review)
- ✅ AI-driven job confirmation (provider marks done → AI asks customer → confirm or dispute)
- ✅ Mock payment and credit system
- ✅ Mutual reviews (customer via chat, provider via REST)
- ✅ Provider booking management (REST endpoints)
- ✅ Customer booking viewing (REST endpoints)
- ✅ In-app notifications
- ✅ FCM token storage (for future push notification support)
- ✅ Map-based location confirmation in booking flow
- ✅ Speech-to-text input in chat
- ✅ AI memory reset between bookings (fresh date/time/location per booking)

The following are **out of scope** for MVP:

- ❌ Real payment gateway integration
- ❌ Push notification sending (FCM token stored but not used)
- ❌ Admin panel
- ❌ Provider onboarding / verification flow
- ❌ File/image uploads in chat
- ❌ Partial credit payments
