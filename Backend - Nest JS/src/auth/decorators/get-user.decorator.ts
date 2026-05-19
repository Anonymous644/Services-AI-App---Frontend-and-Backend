import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { JwtPayload } from '../strategies/jwt.strategy';

/**
 * Extracts the authenticated user's JWT payload from the request.
 * Can optionally extract a specific property from the payload.
 *
 * @example
 * // Get the full JWT payload
 * @GetUser() user: JwtPayload
 *
 * @example
 * // Get just the user ID
 * @GetUser('sub') userId: string
 *
 * @example
 * // Get just the role
 * @GetUser('role') role: UserRole
 */
export const GetUser = createParamDecorator(
  (data: keyof JwtPayload | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as JwtPayload;

    if (!user) {
      return null;
    }

    return data ? user[data] : user;
  },
);
