# Services AI App

> An AI-powered mobile platform that connects customers with service providers through a fully conversational booking experience — built with Flutter, NestJS, and Google Gemini.

---

## Team — Chainspair

| Name              | Role               |
| ----------------- | ------------------ |
| Ashan Ali Zaman   | Team Lead          |
| Sonain Bin Danish | Frontend Developer |
| Azam Dildar       | Backend Developer  |

---

## What Is This?

Services AI App lets customers book home and professional services (plumbing, AC repair, cleaning, etc.) entirely through a chat interface powered by a Google Gemini AI agent. Instead of browsing listings, the customer simply describes their need in natural language — the AI handles everything from finding the right service category, locating nearby providers, presenting ranked options, processing payment, and following up post-job.

Providers get a separate mobile interface to manage their bookings and update job statuses.

---

## Key Features

- **Conversational AI Booking** — Full booking flow driven by a Gemini 2.0 Flash agent over WebSocket. No forms, no dropdowns.
- **Real-Time Streaming** — AI responses stream word-by-word to the app via Socket.IO, with a thinking/CoT phase visible to the user.
- **Vector-Powered Service Matching** — User queries are embedded with `gemini-embedding-001` (768-dim) and matched against service categories via MongoDB Atlas Vector Search (cosine similarity).
- **Geo-Proximity Provider Search** — MongoDB `$geoNear` finds verified providers within 30 km, sorted by distance and rating.
- **AI Provider Ranking** — Gemini analyses all found providers and picks the top 3 with a written rationale for each.
- **Interactive Map Location Picker** — Customers confirm their service location on an in-app Google Map before provider search begins.
- **Role-Based Access** — Separate customer and provider flows with JWT authentication and NestJS RBAC guards.
- **Platform Payment & Splits** — Mock payment with automatic 95/5 provider/platform payout on job completion.
- **Dispute & Review System** — Customers can dispute or confirm job completion via chat; star ratings update provider averages.
- **Speech Input** — Customers can speak their service request directly in the chat.

---

## Tech Stack

| Layer         | Technology                                      |
| ------------- | ----------------------------------------------- |
| Mobile App    | Flutter 3.x, Riverpod (code-gen), Freezed       |
| AI Agent      | Google Gemini 2.0 Flash (`gemini-2.0-flash`)    |
| AI Embeddings | `gemini-embedding-001` — 768 dimensions         |
| Vector Search | MongoDB Atlas Vector Search — cosine similarity |
| Backend       | NestJS v10, Node.js                             |
| Database      | MongoDB Atlas, Prisma v6 ORM                    |
| Real-Time     | Socket.IO (`@nestjs/websockets`)                |
| Maps          | Google Maps Flutter, Geolocator, Geocoding      |
| Auth          | JWT (Passport), bcrypt                          |
| REST Client   | Dio + flutter_secure_storage                    |

---

## Repository Structure

```
Services AI App - Frontend and Backend/
├── Frontend - Flutter/      # Flutter mobile app (customer + provider)
└── Backend - Nest JS/       # NestJS REST API + WebSocket gateway
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Node.js 20+ and Yarn
- MongoDB Atlas cluster with Vector Search index
- Google AI API key (Gemini access)

### Backend

```bash
cd "Backend - Nest JS"
yarn install
cp .env.example .env          # fill in MONGO_URI, JWT_SECRET, GOOGLE_AGENT_PLATFORM_API_KEY
yarn prisma generate
yarn start:dev
```

The server starts on port `8000`. On first run, `SeedService` populates service categories with embeddings.

### Frontend

```bash
cd "Frontend - Flutter"
flutter pub get
# Set the backend IP in lib/core/constants/global_constant.dart
flutter run
```

---

## How the AI Booking Flow Works

```
Customer types "I need AC repair"
        ↓
Gemini searches service categories via vector embedding match
        ↓
Gemini requests customer location → map picker opens
        ↓
Gemini searches providers within 30km via $geoNear
        ↓
Gemini ranks top 3 providers with reasoning
        ↓
Customer selects provider → Gemini creates booking
        ↓
Customer pays → booking confirmed, provider notified
        ↓
Provider marks job done → customer confirms via chat
        ↓
Customer leaves a star review → AIMemory resets
```

All steps happen inside the same chat conversation. The AI maintains state across turns using an `AIMemory` record scoped to the user.

---

## Submitted To

**Google Hackathon 2026**  
Team: **Chainspair**
