# Booking Details Screen — Improvement Implementation Plan

## Goal

Enhance the booking detail screen with a provider info section, embedded map preview,
timestamped status timeline, collapsible AI match reasoning, and a working review dialog.

## Scope of Changes

### 1. Data Model — `lib/models/booking.dart`

- Add `customer: User?` field (populated from API response on GET /bookings/:id)
- Add `provider: User?` field (same)
- The backend already returns these nested objects; the model was just ignoring them
- Trigger: run `flutter pub run build_runner build --delete-conflicting-outputs`

### 2. Dependency — `pubspec.yaml`

- Add `url_launcher` for `tel:` URI (phone dialer) and `geo:` URI (native Maps app)

### 3. Repository — `lib/features/bookings/data/bookings_repository.dart`

- Add `submitReview(bookingId, rating, comment)` → POST /bookings/:id/review

### 4. Controller — `lib/features/bookings/presentation/bookings_controller.dart`

- Add `submitReview(bookingId, rating, comment)` delegating to repository

### 5. Screen — `lib/features/bookings/presentation/booking_details_screen.dart`

#### New widgets added

| Widget                | Description                                                                |
| --------------------- | -------------------------------------------------------------------------- |
| `_ProviderCard`       | Avatar + name + verified badge + rating + jobs + experience + Call button  |
| `_CustomerCard`       | Avatar + name + Call button (shown to provider view only)                  |
| `_LocationMapPreview` | Disabled GoogleMap (160px) pinned at booking coords; tap opens native Maps |
| `_MatchReasoningTile` | Expandable tile showing AI's match reasoning                               |
| `_ReviewBottomSheet`  | Interactive 5-star widget + comment field + Submit → calls submitReview    |

#### Status Timeline enhancement

- Each completed step shows its real timestamp below the dot
  - Unpaid → `createdAt`
  - Pending → `paidAt`
  - In Progress → `initializedAt`
  - Done → `completedAt`

#### Screen section order

1. Status Timeline (with timestamps)
2. Provider Card (customer view) / Customer Card (provider view)
3. Service Info card
4. Location Map Preview
5. Match Reasoning (collapsible, only if available)
6. Payment card
7. Action buttons (provider actions / customer actions incl. Leave a Review)

## API Contracts Used

- `GET /api/bookings/:id` → returns full booking with embedded `provider` and `customer` objects
- `POST /api/bookings/:id/review` → body: `{ rating: number, comment?: string }`

## Notes

- Map only renders if `booking.location?.geo?.coordinates` is non-null (2 elements)
- Call button only renders if the other party's `phone` field is non-null
- Review button only shown when `booking.status == BookingStatus.completed` and user is customer
- Match reasoning only shown when `booking.matchReasoning != null`
