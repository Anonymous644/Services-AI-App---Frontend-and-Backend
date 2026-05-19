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
  │
