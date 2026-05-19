import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { UserRole } from '@prisma/client';

export class GeoPointDto {
  @ApiProperty({ example: 'Point', default: 'Point' })
  @IsString()
  @IsOptional()
  type?: string = 'Point';

  @ApiProperty({
    example: [74.3587, 31.5204],
    description: '[longitude, latitude]',
  })
  @IsNumber({}, { each: true })
  @IsNotEmpty()
  coordinates: number[];
}

export class LocationDto {
  @ApiProperty({ example: '123 Main Street, Gulberg III' })
  @IsString()
  @IsNotEmpty()
  address: string;

  @ApiProperty({ example: 'Lahore' })
  @IsString()
  @IsNotEmpty()
  city: string;

  @ApiPropertyOptional({ example: 'Punjab' })
  @IsString()
  @IsOptional()
  state?: string;

  @ApiPropertyOptional({ example: 'PK', default: 'PK' })
  @IsString()
  @IsOptional()
  country?: string = 'PK';

  @ApiProperty({ type: GeoPointDto })
  @ValidateNested()
  @Type(() => GeoPointDto)
  @IsNotEmpty()
  geo: GeoPointDto;
}

export class SignupDto {
  @ApiProperty({ example: 'john@example.com' })
  @IsEmail({}, { message: 'Please provide a valid email address' })
  @IsNotEmpty()
  email: string;

  @ApiProperty({ example: 'securePass123', minLength: 8 })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  @IsNotEmpty()
  password: string;

  @ApiProperty({ example: 'John' })
  @IsString()
  @IsNotEmpty()
  firstName: string;

  @ApiProperty({ example: 'Doe' })
  @IsString()
  @IsNotEmpty()
  lastName: string;

  @ApiPropertyOptional({ example: '+923001234567' })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({ enum: UserRole, example: UserRole.CUSTOMER })
  @IsEnum(UserRole, { message: 'Role must be one of: CUSTOMER, PROVIDER' })
  @IsNotEmpty()
  role: UserRole;

  @ApiPropertyOptional({ type: LocationDto })
  @ValidateNested()
  @Type(() => LocationDto)
  @IsOptional()
  location?: LocationDto;
}
