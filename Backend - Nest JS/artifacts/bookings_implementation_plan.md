# Bookings Module — Implementation Plan

## Goal

Build the entire Bookings module: WebSocket chat gateway with AI streaming, Gemini tool-calling flow, provider geospatial search, vector search for services, booking CRUD, payment, reviews, notifications, and seeding.

---

## Architecture Overview

```
Mobile App (Customer)                    Mobile App (Provider)
       │                                         │
  [Socket.IO]                              [REST API]
       │                                         │
  ┌────▼──────────────────────────────────────────▼────┐
  │                   NestJS Backend                    │
  │                                                    │
  │  ChatGateway (WebSocket)    BookingsController      │
  │       │                          │                 │
  │       ▼                          ▼                 │
  │   AIService ◄──────────► BookingService            │
  │       │                      │                     │
  │   ┌───┴────┐            ┌────┴─────┐               │
  │   │ Gemini │            │ Prisma   │               │
  │   │  API   │            │ MongoDB  │               │
  │   └────────┘            └──────────┘               │
  └────────────────────────────────────────────────────┘
```

---

## WebSocket Events (Socket.IO)

### Client → Server

| Event             | Payload                             | Description                                                                              |
| ----------------- | ----------------------------------- | ---------------------------------------------------------------------------------------- |
| `send_message`    | `{ content: string }`               | Customer sends a chat message                                                            |
| `action_response` | `{ actionType: string, data: any }` | Customer responds to an action (select provider, pay, confirm completion, submit review) |

### Server → Client

| Event              | Payload                           | Description                                                     |
| ------------------ | --------------------------------- | --------------------------------------------------------------- |
| `thinking`         | `{ message: string }`             | Backend status: "Searching services...", "Finding providers..." |
| `ai_thinking`      | `{ content: string }`             | Gemini's chain-of-thought reasoning (streamed)                  |
| `stream`           | `{ content: string }`             | AI response text chunks (streamed)                              |
| `message_complete` | `{ id, content, actions?, role }` | Final persisted message                                         |
| `error`            | `{ message: string }`             | Error notification                                              |

### Connection Auth

```typescript
// Client connects with JWT
const socket = io('http://api.example.com', {
  auth: { token: 'Bearer eyJ...' }
});

// Server validates on connection
handleConnection(client: Socket) {
  const token = client.handshake.auth.token;
  // Verify JWT, extract userId, attach to socket
}
```

---

## AI Tool-Calling Flow

The AI has access to these tools. Gemini calls them as needed during conversation:

### Tool Definitions

| #   | Tool                 | Trigger                            | What It Does                                                                 |
| --- | -------------------- | ---------------------------------- | ---------------------------------------------------------------------------- |
| 1   | `search_services`    | User describes a need              | Vector search on ServiceCategory, returns top matches with scores            |
| 2   | `search_providers`   | Service identified, location known | Geo query (30km) + category filter + rating sort → returns 10 providers      |
| 3   | `rank_providers`     | 10 providers found                 | AI compares providers on availability, rating, distance, price → picks top 3 |
| 4   | `create_booking`     | Customer selects a provider        | Creates Booking (UNPAID) + updates AIMemory                                  |
| 5   | `process_payment`    | Customer clicks Pay                | Creates mock Transaction, updates booking to PENDING, notifies provider      |
| 6   | `confirm_completion` | Customer confirms job done         | Marks COMPLETED, creates payout transactions, updates provider credits       |
| 7   | `create_dispute`     | Customer reports issue             | Marks DISPUTED, creates Dispute record, freezes payment                      |
| 8   | `find_booking`       | Customer asks about a booking      | Searches bookings by ID, status, or description                              |
| 9   | `submit_review`      | Customer provides rating           | Creates Review record, updates provider average rating                       |

### Tool Call Chain Example (New Booking)

```
User: "I need my AC repaired at home tomorrow at 2pm"

AI → tool: search_services("AC repair")
  → result: [{name: "AC Services", score: 0.94}]

AI → tool: search_providers({categoryId: "...", location: user.location, radius: 30})
  → result: [10 providers with details]

AI: [ai_thinking streams: comparing providers on availability, distance, rating...]

AI → tool: rank_providers({providers: [...], userQuery: "...", requestedTime: "..."})
  → result: [top 3 with reasoning + per-provider pricing]

AI → message: "I found 3 great providers for AC Repair..."
  → actions: [{type: "PROVIDER_SELECTION", data: {providers: [...]}}]

User → action_response: {actionType: "SELECT_PROVIDER", data: {providerId: "..."}}

AI → tool: create_booking({...all details})
  → result: {bookingId: "...", totalAmount: 5000}

AI → message: "Your booking is created! Total: PKR 5,000"
  → actions: [{type: "PAYMENT_REQUEST", data: {bookingId: "...", amount: 5000}}]

User → action_response: {actionType: "PAY", data: {bookingId: "..."}}

AI → tool: process_payment({bookingId: "..."})
AI → message: "Payment confirmed! Your AC Repair is booked for tomorrow at 2:00 PM..."
  → actions: [{type: "BOOKING_CARD", data: {booking details}}]
```

---

## Provider Geospatial Search

```typescript
// Step 1: Geo aggregation via Prisma raw query
const providers = await prisma.$runCommandRaw({
  aggregate: 'users',
  pipeline: [
    {
      $geoNear: {
        near: { type: 'Point', coordinates: [lng, lat] },
        distanceField: 'distance',
        maxDistance: 30000, // 30km in meters
        query: { role: 'PROVIDER', isActive: true },
        spherical: true,
      },
    },
    {
      $lookup: {
        from: 'provider_services',
        localField: '_id',
        foreignField: 'providerId',
        as: 'services',
      },
    },
    { $match: { 'services.categoryId': ObjectId(categoryId) } },
    { $sort: { rating: -1 } },
    { $limit: 10 },
  ],
  cursor: {},
});
```

---

## REST Endpoints (BookingsController)

### Shared (Both Roles)

| Endpoint                   | Method | Auth | Description                                                |
| -------------------------- | ------ | ---- | ---------------------------------------------------------- |
| `/api/bookings`            | GET    | JWT  | List bookings (customer sees theirs, provider sees theirs) |
| `/api/bookings/:id`        | GET    | JWT  | Get single booking details                                 |
| `/api/bookings/:id/review` | POST   | JWT  | Submit a review                                            |

### Provider Only

| Endpoint                   | Method | Auth     | Description                                                |
| -------------------------- | ------ | -------- | ---------------------------------------------------------- |
| `/api/bookings/:id/status` | PATCH  | Provider | Update status (INITIALIZED, PROVIDER_COMPLETED, CANCELLED) |

### Payment (Customer via WebSocket action, but also REST fallback)

| Endpoint                | Method | Auth     | Description          |
| ----------------------- | ------ | -------- | -------------------- |
| `/api/bookings/:id/pay` | POST   | Customer | Process mock payment |

---

## File Structure

```
src/
├── auth/                          # (already done)
├── bookings/
│   ├── bookings.module.ts         # Module definition
│   ├── bookings.controller.ts     # REST endpoints
│   ├── gateway/
│   │   └── chat.gateway.ts        # Socket.IO WebSocket gateway
│   ├── services/
│   │   ├── booking.service.ts     # Booking CRUD + lifecycle
│   │   ├── ai.service.ts          # Gemini integration + tool execution
│   │   ├── chat.service.ts        # Chat + message persistence
│   │   ├── transaction.service.ts # Mock payment + credits
│   │   ├── provider-search.service.ts  # Geo search + vector search
│   │   ├── review.service.ts      # Review CRUD + rating updates
│   │   ├── notification.service.ts # In-app notifications
│   │   └── dispute.service.ts     # Dispute creation
│   ├── tools/
│   │   ├── tool-definitions.ts    # Gemini function declarations
│   │   └── tool-executor.ts       # Routes tool calls to services
│   ├── dto/
│   │   ├── update-status.dto.ts
│   │   ├── create-review.dto.ts
│   │   ├── booking-query.dto.ts
│   │   └── pay-booking.dto.ts
│   └── types/
│       └── actions.types.ts       # Action type definitions
├── seed/
│   └── seed.service.ts            # Seeds services + providers on init
└── utils/
    └── services/
        └── prisma.service.ts      # (exists)
```

---

## Seeding (on AppModule init)

Runs automatically when the database has no service categories:

1. **Seed ServiceCategories** (~10-15 services):
   - AC Services, Plumbing, Electrical, Cleaning, Painting, Carpentry, Pest Control, Appliance Repair, Home Security, Landscaping, etc.
   - Generate 768-dim embeddings for each via Gemini Embedding API
   - Store embeddings in the `embedding` field

2. **Seed Providers** (~5-10 test providers):
   - Different locations around Lahore (GeoJSON coordinates)
   - Each linked to 2-3 service categories via ProviderService
   - Pre-set ratings, availability slots, service radius
   - Passwords hashed with bcrypt

3. **Create Vector Search Index** (manual step in Atlas UI):
   ```json
   {
     "name": "service_category_vector_index",
     "type": "vectorSearch",
     "definition": {
       "fields": [
         {
           "path": "embedding",
           "type": "vector",
           "numDimensions": 768,
           "similarity": "cosine"
         }
       ]
     }
   }
   ```

---

## New Dependencies

```bash
yarn add @google/generative-ai @nestjs/websockets @nestjs/platform-socket.io socket.io
```

---

## Environment Variables (new)

```
GEMINI_API_KEY=your_gemini_api_key
```

---

## Provider Status Update → Customer Notification Flow

### INITIALIZED

```
Provider → PATCH /api/bookings/:id/status {status: "INITIALIZED"}
  → BookingService: update status + initializedAt
  → AIService: generate contextual message for customer
  → ChatGateway: push message_complete to customer WebSocket
  → Message: "Your provider has started working on your AC Repair!"
  → Actions: [{type: "BOOKING_CARD", data: {booking details}}]
```

### PROVIDER_COMPLETED → AI Confirmation Flow

```
Provider → PATCH /api/bookings/:id/status {status: "PROVIDER_COMPLETED"}
  → BookingService: update status
  → AIService: generate confirmation question
  → ChatGateway: push to customer WebSocket
  → Message: "Your provider reports that the AC Repair job is complete. Can you confirm?"
  → Actions: [{type: "CONFIRM_COMPLETION", data: {bookingId, providerName, details}}]

Customer responds (via WebSocket):
  ├── YES (confirms completion):
  │   → AI calls confirm_completion tool
  │   → Booking → COMPLETED
  │   → Provider payout (95%) + platform fee (5%)
  │   → AI asks for review → AWAITING_REVIEW step
  │
  └── NO / reports issue (disputes):
      → AI calls create_dispute tool with customer's reason
      → Booking → DISPUTED
      → Payment → ON_HOLD
      → AI: "Your booking has been put into dispute. Our support will contact you."
      → Provider notified of dispute
```

### CANCELLED (by provider)

```
Provider → PATCH /api/bookings/:id/status {status: "CANCELLED"}
  → BookingService: update status + cancelledAt + cancelledBy=PROVIDER
  → TransactionService: refund to customer credits
  → AIService: generate cancellation message
  → ChatGateway: push to customer WebSocket
  → Message: "Your provider has cancelled the booking. A full refund has been added to your credits."
```

---

## Verification Plan

### Build

- `yarn build` — 0 errors
- Dev server starts with all WebSocket + REST routes

### Seeding

- Services seeded with embeddings on first run
- Providers seeded with locations, services, availability

### Functional Tests (via Swagger + Socket.IO client)

1. **Connect WebSocket** with JWT → authenticated
2. **Send message**: "I need AC repair" → AI responds with service match
3. **Full booking flow**: message → providers → select → pay → confirm
4. **Provider status update** → customer gets real-time WebSocket notification
5. **Dispute flow**: customer says no → dispute created
6. **Review flow**: customer submits rating via chat
7. **Find booking**: customer asks "what's my last booking?" → AI finds it
