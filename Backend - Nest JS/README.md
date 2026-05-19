# Services AI App — Backend API

AI-powered home services marketplace platform. Customers describe what they need in natural language to an AI agent, which searches for matching providers, handles bookings, and manages the full service lifecycle — all through real-time conversation.

---

## Project Info

| Field           | Details                           |
| --------------- | --------------------------------- |
| **Project**     | Services AI App                   |
| **Type**        | Google Hackathon Project          |
| **Author**      | Azam Dildar — azamdev00@gmail.com |
| **License**     | Private / Unlicensed              |
| **API Version** | 1.0                               |

---

## Tech Stack

| Layer           | Technology                                       |
| --------------- | ------------------------------------------------ |
| Framework       | NestJS 10 (Node.js)                              |
| Language        | TypeScript                                       |
| Database        | MongoDB Atlas                                    |
| ORM             | Prisma 6                                         |
| Authentication  | JWT (Passport) — 30-day tokens                   |
| Real-time       | Socket.IO (`/chat` namespace)                    |
| AI              | Google Gemini via `@google/genai`                |
| Vector Search   | MongoDB Atlas Vector Search (768-dim embeddings) |
| API Docs        | Swagger (OpenAPI) at `/docs`                     |
| Package Manager | Yarn                                             |

---

## Architecture Overview

```
src/
├── auth/               # JWT auth, signup/login, guards, decorators
├── bookings/
│   ├── services/
│   │   ├── ai.service.ts            # Gemini AI agent (streaming + tool calling)
│   │   ├── booking.service.ts       # Booking CRUD + lifecycle management
│   │   ├── chat.service.ts          # Chat history persistence
│   │   ├── notification.service.ts  # In-app notifications
│   │   ├── provider-search.service.ts  # Vector + geospatial provider search
│   │   └── review.service.ts        # Ratings and reviews
│   ├── gateway/
│   │   └── chat.gateway.ts          # Socket.IO WebSocket gateway
│   ├── tools/                       # AI tool definitions (function calling)
│   └── dto/                         # Request/response DTOs
├── seed/               # Database seeder (categories + demo users)
└── utils/
    ├── GlobalConstants.ts            # JWT key, Swagger config, validation pipe
    ├── EnviromentVariables.ts        # Env var references
    └── services/
        └── prisma.service.ts        # Prisma client singleton
```

### How the AI Flow Works

1. Customer connects to the `/chat` WebSocket namespace with a JWT token.
2. A message is sent via the `send_message` event.
3. `AIService` processes it through Gemini with tool calling:
   - **Tools available**: search providers, get booking details, create/cancel bookings, process payments, send notifications.
4. Responses stream back in chunks via the `stream_chunk` event.
5. When a booking is created or its status changes, `ChatGateway` pushes updates to the relevant provider in real time.

---

## Prerequisites

- **Node.js** >= 18.x
- **Yarn** (`npm install -g yarn`)
- **MongoDB Atlas** account (free tier works)
- **Google Cloud / Vertex AI** account with Gemini API access
- **NestJS CLI** (`yarn global add @nestjs/cli`)

---

## Environment Variables

Create a `.env` file in the project root:

```env
# ─── App ───────────────────────────────────────────────────────────────────
NODE_ENV=local
PORT=8000

# ─── Database ──────────────────────────────────────────────────────────────
# MongoDB Atlas connection string (include database name at the end)
DATABASE_URL="mongodb+srv://<user>:<password>@<cluster>.mongodb.net/<dbname>?retryWrites=true&w=majority"

# ─── Auth ──────────────────────────────────────────────────────────────────
# Strong random secret — generate with: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
JWT_SECRET=your_strong_random_secret_here

# ─── Google AI (Gemini) ────────────────────────────────────────────────────
# Agent Builder / Vertex AI API key — used by AIService (chat + generation)
GOOGLE_AGENT_PLATFORM_API_KEY=your_agent_platform_api_key_here

# Google AI Studio API key — used for text embeddings (ProviderSearchService)
GEMINI_API_KEY=your_gemini_api_key_here
```

> **Never commit `.env` to version control.** Add it to `.gitignore`.

### Where to get each value

| Variable                        | Where to get it
