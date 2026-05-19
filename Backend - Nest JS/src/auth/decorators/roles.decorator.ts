import { SetMetadata } from '@nestjs/common';
import { UserRole } from '@prisma/client';

export const ROLES_KEY = 'roles';

/**
 * Restricts a route to specific user roles.
 * Must be used with the RolesGuard (registered globally).
 *
 * @example
 * @Roles(UserRole.CUSTOMER)
 * @Get('my-bookings')
 * async getMyBookings() { ... }
 *
 * @example
 * @Roles(UserRole.PROVIDER, UserRole.CUSTOMER)
 * @Get('profile')
 * async getProfile() { ... }
 */
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
