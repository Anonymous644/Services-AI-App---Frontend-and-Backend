# Auth Module — Implementation Plan

## Goal

Implement a complete JWT-based authentication module with signup, login, RBAC, and decorators.

---

## Error Handling Matrix

| Scenario | Endpoint | HTTP Status | Error Message |
|---|---|---|---|
| Duplicate email on signup | POST /auth/signup | 409 Conflict | "A user with this email already exists" |
| Invalid email format | POST /auth/signup | 400 Bad Request | "email must be an email" (class-validator) |
| Missing required fields | POST /auth/signup, /login | 400 Bad Request | "[field] should not be empty" (class-validator) |
| Invalid role enum value | POST /auth/signup | 400 Bad Request | "role must be one of: CUSTOMER, PROVIDER" |
| Password too short | POST /auth/signup | 400 Bad Request | "password must be at least 8 characters" |
| Invalid location data | POST /auth/signup | 400 Bad Request | "latitude/longitude must be a number" |
| Email not found on login | POST /auth/login | 401 Unauthorized | "Invalid email or password" |
| Wrong password on login | POST /auth/login | 401 Unauthorized | "Invalid email or password" |
| Deactivated account login | POST /auth/login | 403 Forbidden | "Your account has been deactivated" |
| No JWT token provided | Any protected route | 401 Unauthorized | "Unauthorized" |
| Invalid/expired JWT | Any protected route | 401 Unauthorized | "Unauthorized" |
| Wrong role for route | Role-restricted route | 403 Forbidden | "You do not have permission to access this resource" |
| User deleted but token valid | GET /auth/me | 401 Unauthorized | "User no longer exists" |

> **Note**: Login uses a generic "Invalid email or password" message for both wrong email and wrong password to prevent user enumeration attacks.

---

## File Structure

```
src/auth/
├── auth.module.ts
├── auth.controller.ts
├── auth.service.ts
├── strategies/
│   └── jwt.strategy.ts
├── guards/
│   ├── jwt-auth.guard.ts
│   └── roles.guard.ts
├── decorators/
│   ├── get-user.decorator.ts
│   ├── roles.decorator.ts
│   └── public.decorator.ts
└── dto/
    ├── signup.dto.ts
    ├── login.dto.ts
    └── auth-response.dto.ts
```

Plus modifications to `app.module.ts` and `GlobalConstants.ts`.

---

## Endpoints

| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/api/auth/signup` | POST | @Public() | Register a new user |
| `/api/auth/login` | POST | @Public() | Login and get JWT |
| `/api/auth/me` | GET | JWT required | Get current user profile |

---

## JWT Payload

```typescript
{ sub: string, email: string, role: UserRole }
```

---

## Verification

1. `yarn build` — 0 errors
2. Test all error scenarios via Swagger at `/docs`
