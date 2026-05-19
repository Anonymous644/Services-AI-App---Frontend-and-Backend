# Testing Guide — Services AI App

## Setup

- **Base URL**: `http://localhost:8000`
- **REST**: Postman
- **WebSocket**: Postman's Socket.IO tab or [Socket.IO Client Tool](https://admin.socket.io)
- **Auth**: Add `Authorization: Bearer <token>` header to all protected routes

---

## 1. Auth — Customer

### Signup

```
POST /api/auth/signup
```

```json
{
  "email": "customer@test.com",
  "password": "test1234",
  "firstName": "Ali",
  "lastName": "Raza",
  "role": "CUSTOMER",
  "location": {
    "address": "F-8, Islamabad",
    "city": "Islamabad",
    "geo": {
      "type": "Point",
      "coordinates": [73.0715, 33.7141]
    }
  }
}
```

### Login

```
POST /api/auth/login
```

```json
{
  "email": "customer@test.com",
  "password": "test1234"
}
```

> Save the `token` from the response. Use it for all subsequent requests.

### Get Profile

```
GET /api/auth/me
Headers: Authorization: Bearer <customer_token>
```

---

## 2. Auth — Provider (use a seeded provider)

```
POST /api/auth/login
```

```json
{
  "email": "ahmed.khan@provider.com",
  "password": "provider123"
}
```

> Save this token separately as `provider_token`.

---

## 3. WebSocket Chat (Customer)

### Connect (Postman Socket.IO)

1. **New** → **Socket.IO Request**
2. **URL**: `http://localhost:8000/chat`

**Auth — pick one method:**

| Method | Where in Postman | Value |
| --- | --- | --- |
| **Headers tab** (easiest) | Headers → Add row | `Authorization` : `Bearer <customer_token>` |
| **Query param** | Change URL to `http://localhost:8000/chat?token=<customer_token>` | — |
| **Auth object** | Not available in Postman UI — use Headers or query param instead | — |

3. Click **Connect**

On connect you'll receive:

- `chat_history` — array of previous messages (empty on first connect)

### Send a Message

**Emit** event: `send_message`

```json
{ "content": "I need my AC repaired, it's leaking water" }
```

**You'll receive these events in sequence:**

| Event              | Description                                           |
| ------------------ | ----------------------------------------------------- |
| `message_complete` | Your own message echoed back (role: USER)             |
| `thinking`         | `{ "message": "Understanding your request..." }`      |
| `thinking`         | `{ "message": "Searching for matching services..." }` |
| `stream`           | AI response chunks: `{ "content": "I can help..." }`  |
| `message_complete` | Final AI response with full text                      |

### AI asks for details — reply naturally:

```json
{ "content": "Tomorrow at 2pm, use my current location" }
```

### Provider search happens — you'll see:

```
thinking: "Finding providers within 30km..."
stream: "I found 3 great providers..."
message_complete: { content: "...", actions: [{ type: "PROVIDER_SELECTION", data: {...} }] }
```

### Select a provider

**Emit** event: `action_response`

```json
{
  "actionType": "SELECT_PROVIDER",
  "data": { "providerId": "<id from PROVIDER_SELECTION action>" }
}
```

### Pay for booking

**Emit** event: `action_response`

```json
{
  "actionType": "PAY",
  "data": { "bookingId": "<id from PAYMENT_REQUEST action>" }
}
```

> Or use REST: `POST /api/bookings/<bookingId>/pay` with customer token.

AI confirms payment and shows booking card.

---

## 4. Provider Actions (REST)

### List provider's bookings

```
GET /api/bookings
Headers: Authorization: Bearer <provider_token>
```

### View single booking

```
GET /api/bookings/<bookingId>
Headers: Authorization: Bearer <provider_token>
```

### Initialize booking (start work)

```
PATCH /api/bookings/<bookingId>/status
Headers: Authorization: Bearer <provider_token>
```

```json
{ "status": "INITIALIZED" }
```

> Customer receives a real-time WebSocket `message_complete` with AI message + BOOKING_CARD action.

### Mark as completed

```
PATCH /api/bookings/<bookingId>/status
Headers: Authorization: Bearer <provider_token>
```

```json
{ "status": "PROVIDER_COMPLETED" }
```

> Customer receives `message_complete` with AI asking to confirm + CONFIRM_COMPLETION action.

---

## 5. Customer Confirms Completion (WebSocket)

### Confirm — booking completes

**Emit** `action_response`:

```json
{
  "actionType": "CONFIRM_COMPLETION",
  "data": { "bookingId": "<bookingId>", "confirmed": true }
}
```

### OR Dispute — booking is disputed

```json
{
  "actionType": "CONFIRM_COMPLETION",
  "data": {
    "bookingId": "<bookingId>",
    "confirmed": false,
    "reason": "Provider left the job incomplete"
  }
}
```

---

## 6. Review

### Customer reviews via chat (WebSocket)

After completion, AI asks for review. Reply naturally:

```json
{ "content": "I'd rate them 5 stars, excellent work!" }
```

Or use `action_response`:

```json
{
  "actionType": "SUBMIT_REVIEW",
  "data": { "rating": 5, "comment": "Excellent work, very professional" }
}
```

### Provider reviews customer (REST)

```
POST /api/bookings/<bookingId>/review
Headers: Authorization: Bearer <provider_token>
```

```json
{
  "rating": 4,
  "comment": "Good customer, clear instructions"
}
```

---

## 7. Other Endpoints

### Customer views their bookings

```
GET /api/bookings
GET /api/bookings?status=COMPLETED
GET /api/bookings/<bookingId>
Headers: Authorization: Bearer <customer_token>
```

### Get notifications

```
GET /api/bookings/notifications/list
Headers: Authorization: Bearer <token>
```

### Provider cancels a booking

```
PATCH /api/bookings/<bookingId>/status
Headers: Authorization: Bearer <provider_token>
```

```json
{ "status": "CANCELLED" }
```

---

## Full Flow Summary

```
1. Customer signup/login → get token
2. Connect WebSocket with token
3. "I need AC repair" → AI searches services
4. AI asks for time/location → customer replies
5. AI finds 10 providers → ranks top 3 → shows cards
6. Customer selects provider → booking created (UNPAID)
7. Customer pays → booking PENDING
8. Provider login → sees booking → INITIALIZED
9. Customer gets real-time notification
10. Provider marks COMPLETED
11. AI asks customer to confirm
12. Customer confirms → COMPLETED + payout
13. AI asks for review → customer rates
14. Provider reviews customer via REST
```
