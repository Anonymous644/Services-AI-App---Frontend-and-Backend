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

| Widget                | Description
