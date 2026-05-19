# API Integration & Enhanced Chat Actions Plan

This plan details the full integration between the Flutter UI and the Node.js backend, focusing on fulfilling your requirements for rich booking details, dynamic location updating, provider distance calculations, and improved interactive AI cards.

## 1. Booking Details & Rich Booking Card
**Goal**: Display complete booking details (category, provider, location, price, dates) beautifully in the chat when a booking is created, paid, or queried.
- **Backend Changes**:
  - Update the `process_payment` tool executor to return the full booking details (including `category`, `subCategory`, `location`, `totalAmount`, etc.) instead of just the ID and status.
  - Update `ai.service.ts` to emit a comprehensive `BOOKING_CARD` action.
- **Frontend Changes**:
  - Update the `ChatBubble` to intercept `BOOKING_CARD` actions and render the actual `BookingCard` widget directly inside the chat flow, instead of simple text buttons.

## 2. Dynamic Location Confirmation & Map Flow
**Goal**: Force the AI to ask for location confirmation and provide map UI buttons.
- **Backend Changes**:
  - Add a new tool to Gemini: `request_location`. The AI will be strictly instructed to call this tool whenever it needs to confirm the booking location.
  - When this tool is called, `ai.service.ts` will emit a `LOCATION_REQUEST` action to the Flutter app.
  - Update `chat.gateway.ts` to handle two new `action_response` events:
    1. `LOCATION_CONFIRMED`: AI proceeds with the registered location.
    2. `LOCATION_UPDATED`: The gateway will update the user's location in the database (`Prisma`) and automatically send a system message to the AI: *"I have updated my location to [New Address]"*.
- **Frontend Changes**:
  - When `LOCATION_REQUEST` is received, `ChatBubble` will render two buttons: **"Confirm Current Location"** and **"Update on Map"**.
  - Clicking **"Update on Map"** will open a full-screen Google Map picker. Once pinned, the app will emit the `LOCATION_UPDATED` action response with the new coordinates and address.

## 3. Provider Distance in Selection Cards
**Goal**: Show the exact distance from the provider to the customer in the UI.
- **Backend Changes**:
  - In `tool-executor.ts`, the `rank_providers` tool currently loses the `distance` field because it refetches providers from the DB. I will modify it to extract the `distance` from the cached `AIMemory` (which holds the original geospatial search results) and include it in the `PROVIDER_SELECTION` payload.
- **Frontend Changes**:
  - Update `ChatBubble` to render a horizontal scrolling list of rich **Provider Cards** when `PROVIDER_SELECTION` is received. These cards will beautifully display the provider's name, rating, AI reasoning, price, and the newly added **Distance (e.g., 2.5 km away)**.

## 4. Other AI Action Improvements
To make the chat feel like a premium native app, I propose upgrading the remaining actions:
- **PAYMENT_REQUEST**: Instead of standard buttons, render a "Checkout Card" inside the chat showing the amount, available wallet credits, and a prominent "Pay Now" button.
- **CONFIRM_COMPLETION**: Render a card showing "Did the provider complete the job?" with two large, distinct buttons: a green "Yes, Job Done" and a red "No, Dispute".
- **REVIEW_REQUEST**: Render an interactive 5-star rating widget directly inside the chat bubble. Tapping the stars will instantly submit the `SUBMIT_REVIEW` action.

## User Review Required
> [!IMPORTANT]
> Please review the plan above. Are you comfortable with rendering these custom widgets (Provider Cards, Checkout Cards, Star Ratings) directly inside the chat bubbles? If you approve, I will begin execution immediately.
