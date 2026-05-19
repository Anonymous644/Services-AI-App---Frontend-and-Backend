# Services AI — Complete System Design

> **For best diagram rendering, view this file at [https://markdownviewer.pages.dev](https://markdownviewer.pages.dev)**

---

## Table of Contents

1. [Overview](#overview)
2. [High-Level Architecture](#high-level-architecture)
3. [Backend Architecture](#backend-architecture)
4. [AI Agent Design](#ai-agent-design)
5. [Data Model](#data-model)
6. [Frontend Architecture](#frontend-architecture)
7. [Key Flows](#key-flows)
8. [Known Flaws & Limitations](#known-flaws--limitations)

---

## Overview

Services AI is a mobile-first SaaS platform that connects **Customers** (who need home/professional services) with **Providers** (who fulfill them). The entire customer-facing booking journey — from describing a need to reviewing the completed job — is orchestrated by an **AI conversational agent** running in real-time over WebSocket. Providers interact via a standard REST API.

---

## High-Level Architecture

```mermaid
graph TB
    subgraph Flutter["Flutter Mobile App"]
        CU["Customer UI<br/>Chat + Bookings + Profile"]
        PU["Provider UI<br/>Bookings + Profile"]
    end

    subgraph NestJS["NestJS Backend :8000"]
        GW["ChatGateway<br/>Socket.IO /chat"]
        BC["BookingsController<br/>REST /api/bookings"]
        AC["AuthController<br/>REST /api/auth"]
        AI["AIService<br/>Gemini Integration"]
        TE["ToolExecutor<br/>10 AI Tools"]
        NS[NotificationService]
    end

    subgraph Data["Data Layer"]
        MDB[("MongoDB Atlas - Prisma ORM")]
        VS["Atlas Vector Search<br/>768-dim embeddings"]
    end

    subgraph Google["Google Cloud"]
        GEM["Gemini 2.0 Flash<br/>Chat + Thinking"]
        EMB["Gemini Embedding<br/>gemini-embedding-001"]
    end

    CU -- "WebSocket send_message / action_response" --> GW
    CU -- "REST auth/bookings" --> AC
    CU -- "REST auth/bookings" --> BC
    PU -- "REST bookings / status updates" --> BC
    GW --> AI
    AI --> GEM
    AI --> TE
    TE --> MDB
    TE --> VS
    VS --> EMB
    BC --> MDB
    BC --> NS
    NS -- "WebSocket push to customer" --> GW
    GW -- "thinking / stream / message_complete" --> CU
```

---

## Backend Architecture

### Module Structure

```mermaid
graph LR
    AppModule --> AuthModule
    AppModule --> BookingsModule
    AppModule -- "OnModuleInit - Seeds DB" --> SeedService

    AuthModule --> AuthController
    AuthController --> AuthService
    AuthService --> Prisma

    BookingsModule --> ChatGateway
    BookingsModule --> BookingsController
    BookingsModule --> AIService
    BookingsModule --> ToolExecutor
    BookingsModule --> ProviderSearchService
    BookingsModule --> BookingService
    BookingsModule --> TransactionService
    BookingsModule --> NotificationService
    BookingsModule --> ReviewService
    BookingsModule --> DisputeService
```

### Guards & Auth Decorators

| Decorator / Guard           | Scope  | Purpose                           |
| --------------------------- | ------ | --------------------------------- |
| `JwtAuthGuard`              | Global | All routes require JWT by default |
| `RolesGuard`                | Global | Checks `@Roles()` metadata        |
| `@Public()`                 | Route  | Skips JWT (signup, login)         |
| `@Roles(UserRole.PROVIDER)` | Route  | RBAC enforcement                  |
| `@GetUser('sub')`           | Param  | Extracts userId from JWT payload  |

### REST Endpoints

| Endpoint                   | Method | Auth     | Description                                      |
| -------------------------- | ------ | -------- | ------------------------------------------------ |
| `/api/auth/signup`         | POST   | Public   | Register customer or provider                    |
| `/api/auth/login`          | POST   | Public   | Login → JWT + user                               |
| `/api/auth/me`             | GET    | JWT      | Current user profile                             |
| `/api/auth/me`             | PATCH  | JWT      | Update profile (name, bio, phone, isActive)      |
| `/api/bookings`            | GET    | JWT      | List bookings (role-filtered)                    |
| `/api/bookings/:id`        | GET    | JWT      | Single booking details                           |
| `/api/bookings/:id/status` | PATCH  | Provider | Set INITIALIZED / PROVIDER_COMPLETED / CANCELLED |
| `/api/bookings/:id/pay`    | POST   | Customer | Mock payment                                     |
| `/api/bookings/:id/review` | POST   | JWT      | Submit review (one per party)                    |

### WebSocket Gateway

Token accepted from **3 sources** on connect:

1. `handshake.auth.token`
2. `Authorization` header
3. `?token=` query param

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant GW as ChatGateway
    participant AI as AIService
    participant DB as MongoDB

    App->>GW: connect (JWT)
    GW->>DB: load chat history
    GW-->>App: chat_history event

    App->>GW: send_message with content
    GW->>AI: processMessage(userId, content)
    AI-->>GW: emit thinking (status text)
    GW-->>App: thinking event
    AI-->>GW: emit ai_thinking (CoT chunks)
    GW-->>App: ai_thinking event
    AI-->>GW: emit stream (text chunks)
    GW-->>App: stream event
    GW->>DB: save ChatMessage
    GW-->>App: message_complete with content and actions

    App->>GW: action_response with actionType and data
    GW->>DB: update user.location (if LOCATION_UPDATED)
    GW->>AI: processMessage(userId, naturalLangMessage)
```

---

## AI Agent Design

### Processing Pipeline

```mermaid
flowchart TD
    A[User message received] --> B[Build system prompt]
    B --> C[Build AIMemory context]
    C --> D{Pre-payment step?}
    D -- Yes --> E["Full context<br/>service, date, location, providers"]
    D -- No --> F["Minimal context<br/>bookingId only + warning"]
    E --> G[Send to Gemini with tool definitions]
    F --> G
    G --> H[Gemini response]
    H --> I{Has tool calls?}
    I -- Yes --> J[Execute tool via ToolExecutor]
    J --> K[Feed result back to Gemini]
    K --> H
    I -- No --> L[Stream response text]
    L --> M[determineActions from tool call names]
    M --> N[Save ChatMessage with actions]
    N --> O[Emit message_complete]

    style D fill:#fef3c7
    style I fill:#fef3c7
```

### Tool Calling Loop (max 10 iterations)

```mermaid
sequenceDiagram
    participant AI as Gemini
    participant TE as ToolExecutor
    participant DB as MongoDB
    participant VS as Vector Search

    Note over AI: User says I need AC repair
    AI->>TE: search_services(query: AC repair)
    TE->>VS: vectorSearch 768-dim embeddings
    VS-->>TE: AC Services - score 0.94
    TE-->>AI: categoryId, name, description

    AI->>TE: request_location()
    TE-->>AI: action LOCATION_REQUEST

    Note over AI: After user confirms location
    AI->>TE: search_providers(categoryId, lng, lat)
    TE->>DB: geoNear within 30km, sort by rating
    DB-->>TE: 10 providers
    TE-->>AI: providers list with full details

    Note over AI: Gemini analyzes all 10 providers
    AI->>TE: rank_providers(topPick, secondPick, thirdPick, overallReasoning)
    TE->>DB: enrich with full provider data
    TE-->>AI: action PROVIDER_SELECTION with rankedProviders

    Note over AI: After user selects provider
    AI->>TE: create_booking(providerId, categoryId, scheduledAt, location)
    TE->>DB: INSERT Booking - status UNPAID
    TE-->>AI: action PAYMENT_REQUEST, bookingId, totalAmount

    Note over AI: After user pays
    AI->>TE: process_payment(bookingId)
    TE->>DB: INSERT Transaction, UPDATE Booking to PENDING
    TE-->>AI: action BOOKING_CARD with full booking data
```

### Provider Discovery Flow

```mermaid
flowchart TD
    A([User describes a need]) --> B[AI calls search_services]
    B --> C[Generate 768-dim embedding\nfrom user query text]
    C --> D[(Atlas Vector Search\ncosine similarity)]
    D --> E{Match found?}
    E -- No --> F[AI replies: service not available]
    E -- Yes --> G[Return best matching ServiceCategory\nid, name, description]

    G --> H[AI calls request_location]
    H --> I[Frontend shows map picker]
    I --> J[User pins location and confirms]
    J --> K[LOCATION_UPDATED sent to backend\nlat, lng, address, city saved to user]

    K --> L[AI calls search_providers\ncategoryId + lat + lng]
    L --> M[(MongoDB geoNear query\nwithin 30km radius)]
    M --> N[Filter: isActive = true\nisVerified = true\nhas ProviderService for categoryId]
    N --> O{Any providers found?}
    O -- No --> P[AI replies: no providers nearby]
    O -- Yes --> Q[Sort by distance then rating\nReturn up to 10 providers]

    Q --> R[AI calls rank_providers\nAnalyses all 10 results]
    R --> S[AI picks topPick, secondPick, thirdPick\nwith overallReasoning]
    S --> T[ToolExecutor enriches picks\nfull User + ProviderService data]
    T --> U[Return PROVIDER_SELECTION action\nwith 3 ranked provider cards]
    U --> V([Frontend shows provider selection sheet])

    style D fill:#e0f2fe
    style M fill:#e0f2fe
    style E fill:#fef3c7
    style O fill:#fef3c7
```

### AI Tools Reference

| #   | Tool                 | Input
