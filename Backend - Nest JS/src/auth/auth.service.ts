import {
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../utils/services/prisma.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { JwtPayload } from './strategies/jwt.strategy';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Register a new user (Customer or Provider).
   * - Checks for duplicate email
   * - Hashes password with bcrypt
   * - Creates user with GeoJSON location
   * - Returns JWT token + sanitized user
   */
  async signup(dto: SignupDto) {
    // Check if email already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email: dto.email.toLowerCase().trim() },
    });

    if (existingUser) {
      throw new ConflictException('A user with this email already exists');
    }

    // Hash password
    const salt = parseInt(process.env.SALT) || 12;
    const hashedPassword = await bcrypt.hash(dto.password, salt);

    // Create user
    const user = await this.prisma.user.create({
      data: {
        email: dto.email.toLowerCase().trim(),
        password: hashedPassword,
        firstName: dto.firstName.trim(),
        lastName: dto.lastName.trim(),
        phone: dto.phone?.trim(),
        role: dto.role,
        location: dto.location
          ? {
              address: dto.location.address,
              city: dto.location.city,
              state: dto.location.state,
              country: dto.location.country || 'PK',
              geo: {
                type: 'Point',
                coordinates: dto.location.geo.coordinates,
              },
            }
          : {
              address: 'Not set',
              city: 'Not set',
              country: 'PK',
              geo: { type: 'Point', coordinates: [0, 0] },
            },
      },
    });

    // Generate JWT token
    const token = this.generateToken(user);

    return {
      accessToken: token,
      user: this.sanitizeUser(user),
    };
  }

  /**
   * Authenticate a user with email and password.
   * - Uses generic error message for both wrong email and wrong password
   *   to prevent user enumeration attacks.
   * - Checks if account is deactivated
   */
  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email.toLowerCase().trim() },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Check if account is deactivated
    if (!user.isActive) {
      throw new ForbiddenException('Your account has been deactivated');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(dto.password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Generate JWT token
    const token = this.generateToken(user);

    return {
      accessToken: token,
      user: this.sanitizeUser(user),
    };
  }

  /**
   * Get the full user profile for the authenticated user.
   * Called by GET /auth/me.
   */
  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        providerServices: {
          include: {
            category: true,
          },
        },
      },
    });

    if (!user) {
      throw new UnauthorizedException('User no longer exists');
    }

    if (!user.isActive) {
      throw new ForbiddenException('Your account has been deactivated');
    }

    return this.sanitizeUser(user);
  }

  /**
   * Update the current user's profile.
   * Called by PATCH /auth/me.
   * bio and isActive are restricted to providers only.
   */
  async updateMe(userId: string, role: UserRole, dto: UpdateProfileDto) {
    if (
      (dto.bio !== undefined || dto.isActive !== undefined) &&
      role !== UserRole.PROVIDER
    ) {
      throw new ForbiddenException(
        'Only providers can update bio and active status',
      );
    }

    const updateData: Record<string, unknown> = {};
    if (dto.firstName !== undefined)
      updateData.firstName = dto.firstName.trim();
    if (dto.lastName !== undefined) updateData.lastName = dto.lastName.trim();
    if (dto.phone !== undefined) updateData.phone = dto.phone.trim();
    if (dto.bio !== undefined) updateData.bio = dto.bio.trim();
    if (dto.isActive !== undefined) updateData.isActive = dto.isActive;

    const user = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      include: {
        providerServices: {
          include: { category: true },
        },
      },
    });

    return this.sanitizeUser(user);
  }

  /**
   * Generate a JWT token with user payload.
   */
  private generateToken(user: {
    id: string;
    email: string;
    role: string;
  }): string {
    const payload: Omit<JwtPayload, 'iat' | 'exp'> = {
      sub: user.id,
      email: user.email,
      role: user.role as any,
    };

    return this.jwtService.sign(payload);
  }

  /**
   * Remove sensitive fields (password) from the user object.
   */
  private sanitizeUser(user: any) {
    const { password, ...sanitized } = user;
    return sanitized;
  }
}
