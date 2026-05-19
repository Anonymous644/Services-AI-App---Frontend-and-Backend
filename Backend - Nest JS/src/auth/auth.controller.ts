import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Post,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiConflictResponse,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { AuthResponseDto, UserResponseDto } from './dto/auth-response.dto';
import { Public } from './decorators/public.decorator';
import { GetUser } from './decorators/get-user.decorator';
import { JwtPayload } from './strategies/jwt.strategy';
import { UserRole } from '@prisma/client';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('signup')
  @ApiOperation({ summary: 'Register a new user (Customer or Provider)' })
  @ApiOkResponse({
    type: AuthResponseDto,
    description: 'User created successfully',
  })
  @ApiConflictResponse({ description: 'A user with this email already exists' })
  async signup(@Body() dto: SignupDto) {
    return this.authService.signup(dto);
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with email and password' })
  @ApiOkResponse({ type: AuthResponseDto, description: 'Login successful' })
  @ApiUnauthorizedResponse({ description: 'Invalid email or password' })
  @ApiForbiddenResponse({ description: 'Account has been deactivated' })
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Get('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiOkResponse({ type: UserResponseDto, description: 'Current user profile' })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  async getMe(@GetUser('sub') userId: string) {
    return this.authService.getMe(userId);
  }

  @Patch('me')
  @ApiBearerAuth()
  @ApiOperation({
    summary:
      'Update current user profile (firstName, lastName, phone; bio and isActive for providers)',
  })
  @ApiOkResponse({ type: UserResponseDto, description: 'Updated user profile' })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  @ApiForbiddenResponse({
    description: 'bio/isActive update attempted by non-provider',
  })
  async updateMe(
    @GetUser('sub') userId: string,
    @GetUser('role') role: UserRole,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.authService.updateMe(userId, role, dto);
  }
}
