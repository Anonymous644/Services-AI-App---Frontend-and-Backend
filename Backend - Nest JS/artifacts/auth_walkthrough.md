# Auth Module — Walkthrough

## Files Created (10 new, 2 modified)

| File | Purpose |
|---|---|
| `src/auth/auth.module.ts` | Module: registers Passport JWT, JwtModule (30d expiry) |
| `src/auth/auth.controller.ts` | 3 endpoints: signup, login, me |
| `src/auth/auth.service.ts` | Business logic: signup, login, getMe with full error handling |
| `src/auth/strategies/jwt.strategy.ts` | Passport JWT strategy + `JwtPayload` interface |
| `src/auth/guards/jwt-auth.guard.ts` | Global guard: requires JWT, respects `@Public()` |
| `src/auth/guards/roles.guard.ts` | Global guard: RBAC, respects `@Roles()` |
| `src/auth/decorators/public.decorator.ts` | `@Public()` — skip auth |
| `src/auth/decorators/roles.decorator.ts` | `@Roles(UserRole.CUSTOMER)` — restrict by role |
| `src/auth/decorators/get-user.decorator.ts` | `@GetUser()` — extract JWT payload from request |
| `src/auth/dto/signup.dto.ts` | Signup validation with nested GeoJSON location |
| `src/auth/dto/login.dto.ts` | Login validation |
| `src/auth/dto/auth-response.dto.ts` | Swagger response DTOs |
| `src/app.module.ts` | **Modified** — imports AuthModule, registers global guards |
| `src/utils/GlobalConstants.ts` | **Modified** — cleaned up Swagger description |

## Test Results

| Test | Expected | Result |
|---|---|---|
| POST /auth/signup (valid) | 201 + token + user | ✅ Pass |
| POST /auth/signup (duplicate email) | 409 "A user with this email already exists" | ✅ Pass |
| POST /auth/login (valid) | 200 + token + user | ✅ Pass |
| POST /auth/login (wrong password) | 401 "Invalid email or password" | ✅ Pass |
| GET /auth/me (with token) | 200 + user profile | ✅ Pass |
| GET /auth/me (no token) | 401 "Unauthorized" | ✅ Pass |
| POST /auth/signup (Provider role) | 201 + token + provider user | ✅ Pass |
| Build check | 0 errors | ✅ Pass |
