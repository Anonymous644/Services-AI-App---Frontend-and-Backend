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

| Variable                        | Where to get it                                                                                                                                                     |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DATABASE_URL`                  | MongoDB Atlas → Connect → Drivers → copy the connection string                                                                                                      |
| `JWT_SECRET`                    | Generate locally: `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`                                                                        |
| `GOOGLE_AGENT_PLATFORM_API_KEY` | Google Agent Builder → [console.cloud.google.com/agent-platform/studio/settings/api-keys](https://console.cloud.google.com/agent-platform/studio/settings/api-keys) |
| `GEMINI_API_KEY`                | Google AI Studio → [aistudio.google.com/apikey](https://aistudio.google.com/apikey)                                                                                 |

> `GOOGLE_AGENT_PLATFORM_API_KEY` drives the AI chat agent (generation + tool calling). `GEMINI_API_KEY` drives text embeddings for vector search. Both are required for full functionality.

---

## MongoDB Atlas Setup

### 1. Create a Cluster

1. Go to [cloud.mongodb.com](https://cloud.mongodb.com) → **Create a new project**.
2. Build a free **M0** cluster (any region).
3. Create a **database user** with read/write permissions.
4. Under **Network Access**, allow your IP (or `0.0.0.0/0` for development).
5. Copy the connection string and set it as `DATABASE_URL` in your `.env`.

### 2. Create the Atlas Vector Search Index

The provider search feature requires a vector search index on the `service_categories` collection. Create it manually from the Atlas UI:

1. Go to your cluster → **Atlas Search** → **Create Search Index**.
2. Select **Atlas Vector Search** (JSON editor).
3. Choose the database and the `service_categories` collection.
4. Name the index exactly: `service_category_vector_index`
5. Paste this definition:

```json
{
  "fields": [
    {
      "type": "vector",
      "path": "embedding",
      "numDimensions": 768,
      "similarity": "cosine"
    }
  ]
}
```

6. Click **Create**. Wait for the index status to show **Active** (takes ~1–2 minutes).

> Without this index, provider search falls back to text search automatically — the app still works but results are less accurate.

### 3. Create the Geospatial (2dsphere) Index

The geospatial provider search uses `$geoNear` to find providers within a radius of the customer's location. MongoDB requires a `2dsphere` index on the `location.geo` field of the `users` collection for this to work.

Run this once from the **MongoDB Atlas UI** → **Collections** → `users` → **Indexes** → **Create Index**, or using `mongosh`:

```js
db.users.createIndex({ 'location.geo': '2dsphere' });
```

**From Atlas UI:**

1. Go to your cluster → **Browse Collections** → select your database → `users` collection.
2. Click the **Indexes** tab → **Create Index**.
3. Set the field: `location.geo` with type `2dsphere`.
4. Click **Create**.

> Without this index, the `searchProviders` query will throw a `$geoNear requires a 2dsphere index` error and provider lookup will fail entirely. This index is **required**.

---

## Installation & Running Locally

### 1. Install dependencies

```bash
yarn install
```

### 2. Push the database schema

This syncs your Prisma schema to MongoDB (creates collections and enforces structure):

```bash
yarn prisma db push
```

### 3. Generate the Prisma client

```bash
yarn prisma generate
```

### 4. Seed the database

Seeds service categories (with AI-generated embeddings) and demo users:

```bash
# Inside NestJS via SeedService — triggered automatically on first onModuleInit
# Or run directly:
yarn dev
# The seed service checks if data exists and skips if already seeded.
```

> The seeder creates a set of service categories with 768-dim embeddings (requires `GEMINI_API_KEY` to be set for embeddings). Demo provider and customer accounts are also created with hashed passwords.

### 5. Start the development server

```bash
yarn dev
```

The server starts on `http://localhost:8000` (or `PORT` from your `.env`).

| URL                          | Description                   |
| ---------------------------- | ----------------------------- |
| `http://localhost:8000/api`  | REST API base                 |
| `http://localhost:8000/docs` | Swagger UI (interactive docs) |
| `ws://localhost:8000/chat`   | Socket.IO WebSocket namespace |

---

## API Reference

Full interactive documentation is available at `/docs` (Swagger) when the server is running.

### Auth — `/api/auth`

| Method  | Endpoint              | Auth   | Description                     |
| ------- | --------------------- | ------ | ------------------------------- |
| `POST`  | `/api/auth/signup`    | Public | Register (Customer or Provider) |
| `POST`  | `/api/auth/login`     | Public | Login, receive JWT token        |
| `GET`   | `/api/auth/me`        | Bearer | Get current user profile        |
| `PATCH` | `/api/auth/me`        | Bearer | Update profile                  |
| `GET`   | `/api/auth/users`     | Bearer | List all users                  |
| `GET`   | `/api/auth/providers` | Bearer | List providers                  |

### Bookings — `/api/bookings`

| Method  | Endpoint                   | Auth     | Description                    |
| ------- | -------------------------- | -------- | ------------------------------ |
| `GET`   | `/api/bookings`            | Bearer   | List bookings (scoped by role) |
| `GET`   | `/api/bookings/:id`        | Bearer   | Get booking details            |
| `PATCH` | `/api/bookings/:id/status` | Provider | Update booking status          |
| `POST`  | `/api/bookings/:id/review` | Customer | Submit a review                |

### Health

| Method | Endpoint  | Description    |
| ------ | --------- | -------------- |
| `GET`  | `/health` | Liveness check |

---

## WebSocket (Socket.IO)

**Namespace:** `/chat`  
**Auth:** Pass the JWT in the handshake:

```js
const socket = io('http://localhost:8000/chat', {
  auth: { token: 'Bearer <your_jwt>' },
});
```

### Events — Client → Server

| Event             | Payload                  | Description                          |
| ----------------- | ------------------------ | ------------------------------------ |
| `send_message`    | `{ message: string }`    | Send a message to the AI agent       |
| `action_response` | `{ actionId, response }` | Confirm/reject an AI-proposed action |

### Events — Server → Client

| Event              | Payload                | Description                        |
| ------------------ | ---------------------- | ---------------------------------- |
| `stream_chunk`     | `{ text: string }`     | Streamed AI response token         |
| `message_complete` | `{ message, actions }` | Full response with pending actions |
| `thinking`         | `{ message: string }`  | AI reasoning status update         |
| `error`            | `{ message: string }`  | Error from the server              |

---

## User Roles

| Role       | Description                                                              |
| ---------- | ------------------------------------------------------------------------ |
| `CUSTOMER` | Browses services, chats with AI, makes bookings, pays, reviews providers |
| `PROVIDER` | Receives booking requests, updates booking status, receives payouts      |

> Role is set at signup and cannot be changed. Most endpoints are accessible to both roles but return role-scoped data.

---

## Booking Lifecycle

```
UNPAID → PENDING → INITIALIZED → PROVIDER_COMPLETED → COMPLETED
              ↘ CANCELLED (customer or provider, before INITIALIZED)
                                              ↘ DISPUTED
```

| Status               | Meaning                                                 |
| -------------------- | ------------------------------------------------------- |
| `UNPAID`             | Booking created by AI, awaiting payment                 |
| `PENDING`            | Payment received, awaiting provider acceptance          |
| `INITIALIZED`        | Provider accepted, work in progress                     |
| `PROVIDER_COMPLETED` | Provider marked as done, awaiting customer confirmation |
| `COMPLETED`          | Customer confirmed — review can now be submitted        |
| `DISPUTED`           | Customer raised a dispute                               |
| `CANCELLED`          | Cancelled by customer or provider                       |

---

## Available Scripts

| Script                 | Description                         |
| ---------------------- | ----------------------------------- |
| `yarn dev`             | Start with hot-reload (development) |
| `yarn build`           | Compile TypeScript to `dist/`       |
| `yarn start:prod`      | Run compiled production build       |
| `yarn lint`            | Lint and auto-fix with ESLint       |
| `yarn test`            | Run unit tests                      |
| `yarn test:cov`        | Run tests with coverage report      |
| `yarn prisma db push`  | Sync schema to MongoDB              |
| `yarn prisma generate` | Regenerate Prisma client            |
| `yarn prisma studio`   | Open Prisma Studio (DB GUI)         |

---

## Production Deployment

1. Set `NODE_ENV=production` in your environment.
2. Set all required env variables (never use `.env` in production — use secret management).
3. Build and start:

```bash
yarn build
yarn start:prod
```

With PM2:

```bash
pm2 start dist/src/main.js --name services-ai-api
```

> Ensure your MongoDB Atlas cluster network access allows your production server's IP.

---

## Security Notes

- JWT tokens expire after **30 days**.
- All routes require a valid JWT by default (`JwtAuthGuard` is applied globally).
- Mark public routes with the `@Public()` decorator.
- Swagger UI is available at `/docs` — restrict this behind a VPN or env check in production.
- Never expose `JWT_SECRET`, `GOOGLE_AGENT_PLATFORM_API_KEY`, or `GEMINI_API_KEY` in code or logs.
